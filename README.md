Poker Bots Project
------------------

*Update 05/23/2012*
I haven't touched this code in a while. May come back to it later when I have some time.

The purpose of this project was to create a poker bot framework in a Ruby DSL.
So far, I implemented the state machine for the game. The next step was to create
agents that started playing, using hill climbing techniques and genetic algorithms for
determining optimal play. Obviously this is a long shot to create something marginally useful.
I started this when I began learning the game. It helped me understand the mechanics better by
implementing the rules in a programming language. I wouldn't put too much faith into this code..

===Resources:===

* (Open Source Poker Bots)[http://www.codingthewheel.com/archives/open-source-poker-and-poker-bots]
* (Poker Hands)[http://en.wikipedia.org/wiki/List_of_poker_hands]
* (Good UI Example)[http://i.d.com.com/i/dl/media/dlimage/20/63/04/206304_large.jpeg]
* (How I Built a Working Poker Bot)[http://www.codingthewheel.com/archives/how-i-built-a-working-poker-bot]
* (Mac OSX Poker Bot Development)[http://pokerai.org/pf3/viewtopic.php?f=79&t=3842&view=previous]
* (Automation for Mac in Cocoa)[http://developer.apple.com/library/mac/#samplecode/SonOfGrab/Introduction/Intro.html]
* (QuickKeys)[http://startly.com/products/quickeys/mac/4/whatisqk.html]

===Thoughts:===

* Use 3 pixel card identification method
* DSL to create rule/constraint based system
 
*given a set of hole cards, execute this set of actions*

Actions available:
CALL: if it has not been raised
      if im later than 7th to act
      if the table has exactly 10 seats
      if its less than 4xBB to call

*Anything to process historical log files and to hook into the UI to display and color code users would be great.*

Metrics in percentages:
VPiP: voluntarily put money into pot
PFR: preflop raise
Agg: Aggression
CPFR: Called preflop raise
FS: Flops seen
AF: aggression factor (coefficient)
TBB: average take in big blinds (not percentage)
BSA: blind steal attempts
FBB folded big blid to steal
CR: check-raised
3B: three bet preflop
F3B: folded to three bet preflop
CBET: continuation bet
FCB: folded to continuation bet
WtS: went to showdown
#: times played

Charting element:
Graph metrics
Pick x and y

Recent hands

Hand replayer?: Relive the glory of the big win. Re-evaluate your play on surprising defeats to work out if you should have played differently.
Components of a Poker Bot
-------------------------

INPUT (Constructing the complete model of the table):
- On MacOSX, can we read a log file?
- Can we screen scrape and OCR
- Must we hook into the application and inject a new shared library?

Input. The input to the system is the poker client software itself, including all its windows, log files, and hand histories, as well as internal (often private) state maintained by the running executable. The goal of the input stage is to interrogate the poker client and produce an accurate model of the table state - your hole cards, names and stack sizes of your opponents, current bets, and so forth.

My Plan:
Hook into the log writer.  We will get the table state in real time. No screen scraping required

PROCESSING:
1. Analyze the table state
2. Make a decision to call, bet, raise, fold or check

Processing. The processing stage runs independently of the other two stages. It's job is to take the table model assembled during the Input phase, and figure out whether to fold, check, bet, raise, or call. That's it. The code that performs this analysis should (ideally) know nothing about screen scraping or interrogating other applications. All it knows is how to take an abstract model of a poker table (probably expressed as some sort of PokerTable class) and determine which betting action to make.

OUTPUT:
- Simulate human input by clicking proper button, set the bet amount, etc.

Output. Once the processing stage has made a decision, the Output stage takes over. It's tasked with clicking the correct buttons on the screen, or simulating whatever user input is necessary in order to actually make the action occur on a given poker site/client.

Use Quickeys to automate the program
Find a way to run quickeys from the command line

DATA MINING:
Using historical data sets, each player will be ranked and categorized.  This will allow the bot to make decisions on the 'emotional' state and history of the other player.

TECHNOLOGY:
Most of this will prototyped in Ruby. The real bot and analytics software will be written in Haskell because correctness is required when writing financial software. We will use the type system to create an application that can be reasoned about and proven to be correct.

