.section .vectors, "ax"
  B _start // Reset vector, jump to the start of the program
  B SERVICE_UND // Undefined instruction vector
  B SERVICE_SVC // Software interrupt vector
  B SERVICE_ABT_INST // Aborted prefetch vector
  B SERVICE_ABT_DATA // Aborted data vector
  .word 0 // Unused vector
  B SERVICE_IRQ // IRQ interrupt vector
  B SERVICE_FIQ // FIQ interrupt vector
.text
.global _start
_start:
  // Set up stack pointers for different modes
  
  // Set up stack for IRQ mode
  MOV R1, #0b11010010 // Switch to IRQ mode, mask interrupts
  MSR CPSR_c, R1
  LDR SP, =0xFFFFFFFF - 3 // Set stack pointer for IRQ mode
  
  // Set up stack for SVC mode
  MOV R1, #0b11010011 // Switch to SVC mode, mask interrupts
  MSR CPSR, R1
  LDR SP, =0x3FFFFFFF - 3 // Set stack pointer for SVC mode
  BL CONFIG_GIC // Configure General Interrupt Controller (GIC)
  
  // Enable pushbutton KEY interrupts
  LDR R0, =0xFF200050 // Address of pushbutton
  MOV R1, #0xF // Enable interrupts for all 4 pushbuttons
  STR R1, [R0, #0x8] // Write to interrupt mask register
  
  // Enable IRQ interrupts
  MOV R0, #0b01010011 // Unmask IRQ interrupts, switch to SVC mode
  MSR CPSR_c, R0 // Apply changes to CPSR
  
MODS:
  // Initialize game values
  BL RESET_VALUE // Reset game values
  LDR R0, =0xff200040 // Address of switches
  LDR R1, [R0] // Read switches' state
  
  // Check switch states to determine game mode
  CMP R1, #2 // 3+0 (Switch 1)
  BEQ THREE_GAME // If switch 1 is on, branch to THREE_GAME
  CMP R1, #4 // 3+2 (Switch 2)
  LDREQ R0, =EXTRA
  MOVEQ R1, #1
  STREQ R1, [R0]
  BEQ THREE_GAME // If switch 2 is on, branch to THREE_GAME
  CMP R1, #8 // 5+0 (Switch 3)
  BEQ FIVE_GAME // If switch 3 is on, branch to FIVE_GAME
  CMP R1, #16 // 5+2 (Switch 4)
  LDREQ R0, =EXTRA
  MOVEQ R1, #1
  STREQ R1, [R0]
  
  BEQ FIVE_GAME // If switch 4 is on, branch to FIVE_GAME
  B THREE_GAME // Default to 3+0 game mode
  
THREE_GAME:
  // Initialize time for 3+0 game mode
  MOV R5, #0 // Player1's tens digit
  MOV R6, #0 // Player1's units digit
  MOV R7, #3 // Player1's initial time in minutes
  LDR R1, =PLAYER1
  MOV R2, #300 // 300 seconds (5 minutes)
  STR R2, [R1] // Set Player1's time
  LDR R1, =PLAYER2
  STR R2, [R1] // Set Player2's time
  B INIT_DISPLAY // Initialize display
  
FIVE_GAME:
  // Initialize time for 5+0 game mode
  MOV R5, #0 // Player1's tens digit
  MOV R6, #0 // Player1's units digit
  MOV R7, #5 // Player1's initial time in minutes
  LDR R1, =PLAYER1
  MOV R2, #500 // 500 seconds (8 minutes 20 seconds)
  STR R2, [R1] // Set Player1's time
  LDR R1, =PLAYER2
  STR R2, [R1] // Set Player2's time
  B INIT_DISPLAY // Initialize display
  
INIT_DISPLAY:
  // Initialize the 7-segment display
  BL FIRST_DISPLAY // Call the subroutine to display the initial time
  
LEDS:
  // Enable LEDs to indicate active player
  LDR R0, =0xff200000 // Address of LEDs
  MOV R1, #1 // Turn on first LED
  STR R1, [R0] // Write to LED register
  LDR R0, =RESET
  LDR R1, [R0]
  CMP R1, #1 // Check if reset flag is set
  BEQ MODS // If reset, branch to MODS
  LDR R0, =STOP
  LDR R1, [R0]
  CMP R1, #0 // Check if stop flag is set
  BEQ LEDS // If not stopped, loop back
  
  // Reset registers and configure private timer
  BL RESET_REGISTERS
  BL CONFIG_PRIV_TIME // Configure private timer for game timing
  BL RESET_REGISTERS
  LDR R0, =0xff200000 // Address of LEDs
  MOV R1, #0b1000000000 // Turn on a specific LED pattern
  STR R1, [R0] // Write to LED register
  
MAIN_LOOP:
  // Main loop to handle game logic and interrupts
  LDR R0, =RESET
  LDR R1, [R0]
  CMP R1, #1 // Check if reset flag is set
  BEQ MODS // If reset, branch to MODS
  B LOOP // Loop back
  
FIRST_DISPLAY:
  // Initial display of the time on 7-segment display
  PUSH {R0-R4,LR}
  LDR R0, =0xff200020 // Address of 7-segment display
  LDR R1, =HEXTABLE // Lookup table for hex values
  MOV R4, #0 // Initialize register for first half
  MOV R2, #0 // Temporary register for hex values
  MOV R3, #0 // Initialize register for second half
  
  // Display Player1's and Player2's initial times
  LDRB R2, [R1, R5] // Load hex value for Player1's tens digit
  ORR R4, R4, R2 // Store hex value in R4
  LSL R4, #8 // Shift left by 8 bits
  LDRB R2, [R1, R7] // Load hex value for Player1's hundreds digit
  ORR R4, R4, R2 // Store hex value in R4
  LSL R4, #8 // Shift left by 8 bits
  LDRB R2, [R1, R6] // Load hex value for Player1's units digit
  ORR R4, R4, R2 // Store hex value in R4
  LSL R4, #8 // Shift left by 8 bits
  LDRB R2, [R1, R5] // Load hex value for Player1's tens digit
  ORR R4, R4, R2 // Store hex value in R4
  LDRB R2, [R1, R7] // Load hex value for Player2's hundreds digit
  ORR R3, R3, R2 // Store hex value in R3
  LSL R3, #8 // Shift left by 8 bits
  LDRB R2, [R1, R6] // Load hex value for Player2's units digit
  ORR R3, R3, R2 // Store hex value in R3
  STR R4,[R0] // Display first half on 7-segment
  STR R3,[R0, #16] // Display second half on 7-segment
  POP {R0-R4,LR} // Return from subroutine
  BX LR // Return from subroutine
  
DISPLAY:
  // Display current time on 7-segment display
  PUSH {R0-R4,LR}
  PUSH {R8-R12}
  
  // Format Player2's time
  LDR R1, =PLAYER2
  CMP R9, #6 // Check if Player2's tens digit is 6
  ADDEQ R10, R10, #1 // Increment hundreds digit if tens digit is 6
  MOVEQ R9, #0 // Reset tens digit if it is 6
  MOVEQ R12, #100 // Constant for 100
  MULEQ R0,R10,R12 // Multiply hundreds digit by 100
  ADDEQ R0,R0,R8 // Add units digit to result
  STREQ R0, [R1] // Store formatted time
  
  // Format Player1's time
  LDR R1, =PLAYER1
  CMP R6, #6 // Check if Player1's tens digit is 6
  ADDEQ R7, R7, #1 // Increment hundreds digit if tens digit is 6
  MOVEQ R6, #0 // Reset tens digit if it is 6
  MOVEQ R12, #100 // Constant for 100
  MULEQ R0,R7,R12 // Multiply hundreds digit by 100
  ADDEQ R0,R0,R5 // Add units digit to result
  STREQ R0, [R1] // Store formatted time
  
  LDR R0, =0xff200020 // Address of 7-segment display
  LDR R1, =HEXTABLE // Lookup table for hex values
  MOV R4, #0 // Initialize register for first half
  MOV R2, #0 // Temporary register for hex values
  MOV R3, #0 // Initialize register for second half
  
  // Display Player1's and Player2's times
  LDRB R2, [R1, R8] // Load hex value for Player2's units digit
  ORR R4, R4, R2 // Store hex value in R4
  LSL R4, #8 // Shift left by 8 bits
  LDRB R2, [R1, R7] // Load hex value for Player1's hundreds digit
  ORR R4, R4, R2 // Store hex value in R4
  LSL R4, #8 // Shift left by 8 bits
  LDRB R2, [R1, R6] // Load hex value for Player1's tens digit
  ORR R4, R4, R2 // Store hex value in R4
  LSL R4, #8 // Shift left by 8 bits
  LDRB R2, [R1, R5] // Load hex value for Player1's units digit
  ORR R4, R4, R2 // Store hex value in R4
  LDRB R2, [R1, R10] // Load hex value for Player2's hundreds digit
  ORR R3, R3, R2 // Store hex value in R3
  LSL R3, #8 // Shift left by 8 bits
  LDRB R2, [R1, R9] // Load hex value for Player2's tens digit
  ORR R3, R3, R2 // Store hex value in R3
  STR R4,[R0] // Display first half on 7-segment
  STR R3,[R0, #16] // Display second half on 7-segment
  
  // Decrease time
  LDR R0, =START
  LDR R1, [R0]
  CMP R1, #0 // Check if it is Player1's turn
  BEQ TIME1_DECREASE // If Player1's turn, decrease Player1's time
  
TIME2_DECREASE:
  LDR R1, =PLAYER2
  LDR R0, [R1] // Load Player2's time
  ADD R2,R8,R9
  CMP R2, #0 // Check if tens digit is zero
  SUBEQ R10, R10, #1 // Decrement hundreds digit if tens digit is zero
  MOVEQ R9, #5 // Set tens digit to 5 if zero
  MOVEQ R8, #9 // Set units digit to 9 if zero
  MOVEQ R11, #10 // Constant for 10
  MOVEQ R12, #100 // Constant for 100
  MULEQ R10,R10,R12 // Multiply hundreds digit by 100
  MULEQ R9, R9, R11 // Multiply tens digit by 10
  ADDEQ R10,R10,R9 // Add tens digit to result
  ADDEQ R10,R10,R8 // Add units digit to result
  STREQ R10, [R1] // Store new time
  SUBNE R0, R0, #1 // Decrement time by 1 if not zero
  STRNE R0, [R1] // Store new time
  B DISPLAY_END // End display update
  
TIME1_DECREASE:
  LDR R1, =PLAYER1
  LDR R0, [R1] // Load Player1's time
  ADD R2,R5,R6
  CMP R2, #0 // Check if tens digit is zero
  SUBEQ R7, R7, #1 // Decrement hundreds digit if tens digit is zero
  MOVEQ R6, #5 // Set tens digit to 5 if zero
  MOVEQ R5, #9 // Set units digit to 9 if zero
  MOVEQ R11, #10 // Constant for 10
  MOVEQ R12, #100 // Constant for 100
  MULEQ R7,R7,R12 // Multiply hundreds digit by 100
  MULEQ R6, R6, R11 // Multiply tens digit by 10
  ADDEQ R7,R7,R6 // Add tens digit to result
  ADDEQ R7,R7,R5 // Add units digit to result
  STREQ R7, [R1] // Store new time
  SUBNE R0, R0, #1 // Decrement time by 1 if not zero
  STRNE R0, [R1] // Store new time
  
DISPLAY_END:
  POP {R8-R12}
  POP {R0-R4,LR}
  BX LR // Return from subroutine
  
// Pushbutton Interrupt Service Routine (ISR)
.equ KEY_BASE, 0xFF200050 // Base address of pushbuttons
.equ LED_BASE, 0xFF200000 // Base address of LEDs

KEY_ISR:
  LDR R0, =KEY_BASE
  LDR R1, [R0, #0xC] // Read pushbutton interrupt status
  MOV R2, #0xF // Mask for pushbuttons
  STR R2, [R0, #0xC] // Clear pushbutton interrupt status

START_STOP:
  MOV R3, #0x1
  ANDS R3, R3, R1 // Check KEY0 (start/stop button)
  BEQ PLAYER1_TURN_DONE // If not pressed, check next button
  PUSH {R0-R4,LR}
  LDR R1, =0xfffec608
  LDR R4, [R1]
  EOR R3, R4, #1 // Toggle game start/stop state
  STR R3, [R1]
  
  LDR R1, =STOP
  LDR R4, [R1]
  CMP R4, #1
  LDREQ R0, =0xff200000
  MOVEQ R1, #1
  STREQ R1, [R0]
  LDRNE R0, =0xff200000
  MOVNE R1, #0b1000000000
  STRNE R1, [R0]
  LDR R1, =STOP
  LDR R4, [R1]
  EOR R3, R4, #1
  STR R3, [R1]
  POP {PC,R0-R4}
  
PLAYER1_TURN_DONE:
  LDR R0, =STOP
  LDR R0, [R0]
  CMP R0, #0 // Check if game is stopped
  BEQ PLAYER2_TURN_DONE
  MOV R3, #0x2
  ANDS R3, R3, R1 // Check KEY1 (Player1 turn done)
  BEQ PLAYER2_TURN_DONE
  LDR R3, =START
  LDR R7, [R3]
  CMP R7, #0 // If it's Player1's turn
  BNE END_KEY_ISR
  
  LDR R7, =EXTRA
  LDR R7, [R7]
  CMP R7, #1 // Check if extra time flag is set
  LDREQ R0, =PLAYER1
  LDREQ R1, [R0]
  ADDEQ R1, R1, #3 // Add 2 seconds to Player1's time
  STREQ R1, [R0]
  LDR R3, =START
  LDR R7, [R3]
  EOR R7, R7, #1 // Toggle turn flag
  STR R7, [R3]
  B END_KEY_ISR
  
PLAYER2_TURN_DONE:
  LDR R0, =STOP
  LDR R0, [R0]
  CMP R0, #0 // Check if game is stopped
  BEQ RESET_GAME
  MOV R3, #0x4
  ANDS R3, R3, R1 // Check KEY2 (Player2 turn done)
  BEQ RESET_GAME
  LDR R3, =START
  LDR R7, [R3]
  CMP R7, #1 // If it's Player2's turn
  BNE END_KEY_ISR
  
  LDR R7, =EXTRA
  LDR R7, [R7]
  CMP R7, #1 // Check if extra time flag is set
  LDREQ R0, =PLAYER2
  LDREQ R1, [R0]
  ADDEQ R1, R1, #3 // Add 2 seconds to Player2's time
  STREQ R1, [R0]
  LDR R3, =START
  LDR R7, [R3]
  EOR R7, R7, #1 // Toggle turn flag
  STR R7, [R3]
  B END_KEY_ISR
  
RESET_GAME:
  MOV R3, #0x8
  ANDS R3, R3, R1 // Check KEY3 (reset game)
  BEQ END_KEY_ISR
  LDR R3, =RESET
  MOV R7, #1
  STR R7, [R3] // Set reset flag
  B END_KEY_ISR

END_KEY_ISR:
  BX LR // Return from ISR

PRIV_TIME_ISR:
  // Private Timer ISR
  LDR R0, =0xfffec60c // Timer interrupt status register
  MOV R2, #1
  STR R2, [R0] // Clear interrupt status
  LDR R0, =START
  LDR R1, [R0]
  CMP R1, #0 // Check whose turn it is
  LDREQ R0, =PLAYER1 // If it's Player1's turn
  LDREQ R1, [R0]
  LDRNE R0, =PLAYER2 // If it's Player2's turn
  LDRNE R1, [R0]
  
  CMP R1, #0 // Check if time is up
  BLEQ RESET_VALUE // If time is up, reset game
  BEQ end // If time is up, reset game
  LDR R0, =0xff200020 // Address of 7-segment display
  B SHIFTING // Update display with new time
  BX LR // Return from ISR

SHIFTING:
  // Shift the digits for display
  PUSH {R0-R12,LR}
  LDR R1, =PLAYER1 // Load Player1's time
  LDR R0, [R1]
  
  // Convert Player1's time to decimal and store digits in R5, R6, R7
  MOV R10,R0
  MOV R11,#10
  BL DIV // Divide R10 by R11
  MOV R5,R10 // Store quotient in R5
  MOV R0,R12 // Store remainder in R0
  MOV R10,R0
  MOV R11,#10
  BL DIV // Divide R10 by R11
  MOV R6,R10 // Store quotient in R6
  MOV R0,R12 // Store remainder in R0
  MOV R10,R0
  MOV R11,#10
  BL DIV // Divide R10 by R11
  MOV R7,R10 // Store quotient in R7
  MOV R0,R12 // Store remainder in R0
  
  // Convert Player2's time to decimal and store digits in R8, R9, R10
  LDR R1, =PLAYER2
  LDR R0, [R1]
  MOV R10,R0
  MOV R11,#10
  BL DIV // Divide R10 by R11
  MOV R8,R10 // Store quotient in R8
  MOV R0,R12 // Store remainder in R0
  MOV R10,R0
  MOV R11,#10
  BL DIV // Divide R10 by R11
  MOV R9,R10 // Store quotient in R9
  MOV R0,R12 // Store remainder in R0
  MOV R10,R0
  MOV R11,#10
  BL DIV // Divide R10 by R11
  MOV R10,R10 // Store quotient in R10
  MOV R0,R12 // Store remainder in R0
  BL DISPLAY // Call display subroutine
  POP {R0-R12,PC} // Return from subroutine
  
RESET_REGISTERS:
  PUSH {R0-R12}// Reset all registers to zero
MOV R0, #0
MOV R1, R0
MOV R2, R0
MOV R3, R0
MOV R4, R0
MOV R5, R0
MOV R6, R0
MOV R7, R0
MOV R8, R0
MOV R9, R0
MOV R10, R0
MOV R11, R0
MOV R12, R0
POP {R0-R12}
  BX LR // Return from subroutine
  
DIV:
  // Division subroutine
  PUSH {R0-R9,LR}
  MOV R12 , #0 // Initialize quotient to 0
  SUB R12,R12,#1 // Set remainder to -1
  CMP R10,R11 // Compare dividend and divisor
  MOVMI R12,#0 // If dividend < divisor, set quotient to 0
  BMI LEAVE // Branch to leave if dividend < divisor
  
DIV_LOOP:
  SUBS R10,R10,R11 // Subtract divisor from dividend
  ADD R12,R12,#1 // Increment quotient
  BGE DIV_LOOP // Repeat if dividend >= 0
  CMP R10, #0 // Check if remainder is zero
  ADDLT R10,R10,R11 // If remainder < 0, add divisor back
  
LEAVE:
  POP {R0-R9,LR}
  BX LR // Return from subroutine
  
RESET_VALUE:
  // Reset game values and state
  LDR R2, =0xfffec600 // A9 Private Timer base address
  MOV R4, #0b000 // Disable timer
  STR R4, [R2, #8] // Write to control register
  LDR R0, =START
  MOV R1, #0
  STR R1, [R0] // Reset start flag
  LDR R2, =STOP
  MOV R4, #0
  STR R4, [R2] // Reset stop flag
  LDR R0, =RESET
  MOV R1, #0
  STR R1, [R0] // Reset reset flag
  LDR R0, =EXTRA
  MOV R1, #0
  STR R1, [R0] // Reset extra time flag
  LDR R0, =0xff200000 // Address of LEDs
  LDR R1, =0x3ff // All LEDs on
  STR R1, [R0] // Write to LED register
  
  B SHIFTING // Display 000 on 7-segment
  BX LR // Return from subroutine
  
// Configure General Interrupt Controller (GIC)
CONFIG_GIC:
  PUSH {LR}
  MOV R0, #73 // Pushbutton KEY interrupt ID
  MOV R1, #1 // CPU0
  BL CONFIG_INTERRUPT // Configure interrupt for pushbutton
  MOV R0, #29 // Timer interrupt ID
  BL CONFIG_INTERRUPT // Configure interrupt for timer
  LDR R0, =0xFFFEC100 // CPU Interface
  LDR R1, =0xFFFF // Priority Mask
  STR R1, [R0, #0x04] // Set priority mask
  MOV R1, #1 // Enable CPU Interface
  STR R1, [R0] // Enable interface
  LDR R0, =0xFFFED000 // Distributor Interface
  STR R1, [R0] // Enable distributor
  POP {PC} // Return from subroutine
  
CONFIG_INTERRUPT:
  PUSH {R4-R5, LR}
  LSR R4, R0, #3 // Calculate register offset
  BIC R4, R4, #3 // Clear bottom 2 bits
  LDR R2, =0xFFFED100 // Distributor Base Address
  ADD R4, R2, R4 // Calculate address of enable register
  AND R2, R0, #0x1F // Mask for lower 5 bits
  MOV R5, #1
  LSL R2, R5, R2 // Calculate bit mask for interrupt
  LDR R3, [R4] // Read current register value
  ORR R3, R3, R2 // Enable interrupt
  STR R3, [R4] // Write back to enable register
  BIC R4, R0, #3 // Calculate priority register offset
  LDR R2, =0xFFFED800 // Priority Base Address
  ADD R4, R2, R4 // Calculate address of priority register
  AND R2, R0, #0x3 // Mask for lower 2 bits
  ADD R4, R2, R4 // Calculate final address
  STRB R1, [R4] // Set priority for interrupt
  POP {R4-R5, PC} // Return from subroutine
  
CONFIG_PRIV_TIME:
  // Configure the private timer
  LDR R2, =0xfffec600 // A9 Private Timer base address
  LDR R3, =200000000 // Load value for 1 second
  STR R3, [R2] // Set the load value
  MOV R3, #0b111 // Enable timer and interrupt
  STR R3, [R2, #8] // Write to control register
  MOV R2, #0
  MOV R3, #0
  BX LR // Return from subroutine
  
// Exception service routines
SERVICE_UND:
  B SERVICE_UND
  
SERVICE_SVC:
  B SERVICE_SVC

SERVICE_ABT_DATA:
  B SERVICE_ABT_DATA

SERVICE_ABT_INST:
  B SERVICE_ABT_INST

SERVICE_IRQ:
  PUSH {R0-R7, LR}
  LDR R4, =0xFFFEC100 // Address of GIC CPU Interface
  LDR R5, [R4, #0x0C] // Read ICCIAR (Interrupt Acknowledge Register)

FPGA_IRQ1_HANDLER:
  CMP R5, #73 // Check if interrupt ID is for pushbutton
  BLEQ KEY_ISR // Branch to pushbutton ISR if true
  CMP R5, #73
  BEQ EXIT_IRQ // Branch to exit if true

FPGA_IRQ2_HANDLER:
  CMP R5, #29 // Check if interrupt ID is for timer
  BLEQ PRIV_TIME_ISR // Branch to timer ISR if true
  CMP R5, #29
  BEQ EXIT_IRQ // Branch to exit if true

UNEXPECTED:
  BNE UNEXPECTED // Branch to itself if unexpected interrupt

EXIT_IRQ:
  // Write to ICCEOIR (End of Interrupt Register)
  STR R5, [R4, #0x10] // Signal end of interrupt
  POP {R0-R7, LR} // Restore registers
  SUBS PC, LR, #4 // Return from ISR

SERVICE_FIQ:
  B SERVICE_FIQ // Branch to FIQ handler (not implemented)

END: B END
// Data section
START: .word 0x0 // Whose turn it is
STOP: .word 0x0 // Start/stop game flag
RESET: .word 0x0 // Reset game flag
EXTRA: .word 0x0 // Extra time flag for x+2 games
PLAYER1: .word 0x0 // Player1's time
PLAYER2: .word 0x0 // Player2's time
HEXTABLE: .byte 0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F // Hex values
for 7-segment display
.end
