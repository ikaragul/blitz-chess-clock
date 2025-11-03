# Blitz Chess Clock

Abstract
  In this project, we’ve created a Blitz Chess Clock, which is essentially a chess clock designed
to be used specifically for Blitz games. Blitz games in chess are very short and quick, as their name
suggests, which in turn requires quick and efficient moves, making timekeeping very hard without
the need for an outside device. We have written this code in order to eliminate this need and
make every Blitz Chess fans lives easier, since now they can play anywhere they want without the
need to worry about time keeping just by running this code. The code is written to follow the
rules of a Blitz game. Blitz games can have multiple variations. It is also possible to switch to the
exact variation that the user wants to play by just flicking a switch. Upon choosing the variation
and resetting the displays accordingly, the game is ready to be started, and it is started when one
of the players starts the timer by clicking the designated button for it. The game can be paused,
resumed, and reset anytime the user wants. The user can also end their turn via a push button. Overall,
it is an easy-to-use program for any chess lover and grants them the ability to play a game of time
management and speed like Blitz chess anywhere.

About The Project
  Our aim in this project was to create a Blitz chess clock using the tools that are given to
us and give the chess players a way that allows them to play such a time-sensitive chess style
anywhere in the world, since they would have all the functionality of a chess clock. Firstly,
we’ve started by analysing the things we can and can’t do with the tools that we have. In order
to get a clearer approach to the project and be able to fully utilize what we have on our
hands. After testing the boundaries part, we’ve started implementing functions that are
desired in a Blitz Chess Clock.

  In order to replicate a Chess clock, player times are shown in 7-segment displays and are
controlled by the use of push buttons as well as switches, with additional help from LEDs. Switches
work in changing the variation of the Blitz game according to the official formats. Switch 1 works
in a 3|0 format, which gives both players 3 minutes each at the start. Switch 2 works in a 3|2 format
which gives both players 3 minutes each at the start same as Switch 1 but the point it differs from
Switch 1 is that Switch 2 also gives the player 2 seconds back each time they end their turn, making
each side last more than 3 minutes if fast and efficient moves are made. Switch 3 works in 5|0
format which gives both players 5 minutes each at the start of the game. Switch 4 works in 5|2
format which gives both players 5 minutes each at the start of the game, and on top of that, just
like it was on the 3|2 variation, it gives 2 seconds back when the user ends their turn. The displays
are formatted to show the starting and remaining times of the players in M:SS
(Minute:SecondSecond) format first digit used as the minute, and the other two used as seconds
utilizing all 6 of the 7-segment displays that were given this way. The three on the left shows the
time of Player 2, while the three on the right shows the time of Player 1, giving a display of
500500 in the 7-segment displays for variations 3 and 4 at the very start of the game. LEDs are
used as indicators in the project to indicate the game's status, answering questions such as
whether the game is currently paused or not, whether it was started or is waiting in an idle position.
LEDs are what show the status of the game. If LED 0 is on, that means the  code is running and
clock is ready to be used in a game of chess. LED 0 will always light up at the start of the game
before the countdown has started, and when the game is paused. For the time being, the countdowns
are running as well as the game LED 9 lights up to indicate the game is in progress. Once one of the
timers of the players hit 0, all LEDs from 0 to 9 will light up, indicating that one player has run out
of time. However, for the countdown timers to work flawlessly and without errors, “Function
clobbered callee-saved register” option on the settings part should be disabled. Otherwise, the
code won’t be able to run and give out multiple clobbered register errors when trying to run.
  
  Push buttons play a major part in using the chess clock, they are the essential part of the
code for if there were no LEDs Chess Clock would have been less complete but still alright, even
with the switches user wouldn’t have had the ability to change variations but since we’ve set a
default variation for the games to take place without flicking a single switch the user could have
played the 3|0 variation with ease. However, push buttons are necessary in starting, pausing,
resuming, and resetting the game as well as ending the turns of each user. Push Button 0 starts
the timers and the game while also pausing and resuming when needed. Push Button 1 is the
button that Player 1 pushes to end their turn and stop their timer from counting down. Push
Button 2 is where Player 2 pushes to end their turn and stop their time from counting down the
same way. This procedure stops the timer of the player who pushes their button, and at the same
time starts the timer on the opponent's side. Push Button 3 is used in resetting the game when
needed and is necessary to be pushed once a switch is flicked in order to change game variations.

  All in all, the Blitz Chess Clock is a fully operational project that can be used in a variety of
situations with ease. It is a design that uses multiple tools and approaches that we have learned
in our class, ultimately showing all the work we have put in the semester.
Figure 6 ( Variation 5|0 )
Figure 7 ( Variation 5|2 )
FLOWCHART OF THE PROJECT
