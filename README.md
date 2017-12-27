# adventofcode-rb-2017

[![Build Status](https://travis-ci.org/petertseng/adventofcode-rb-2017.svg?branch=master)](https://travis-ci.org/petertseng/adventofcode-rb-2017)

It's the time of the year to do [Advent of Code](http://adventofcode.com) again.

Your once-in-a-lifetime opportunity to get internet points.

The solutions are written with the following goals, with the most important goal first:

1. **Speed**.
   Where possible, use efficient algorithms for the problem.
   Solutions that take more than a second to run are treated with high suspicion.
   This need not be overdone; micro-optimisation is not necessary.
2. **Readability**.
3. **Less is More**.
   Whenever possible, write less code.
   Especially prefer not to duplicate code.
   This helps keeps solutions readable too.

All solutions are written in Ruby (with some particularly slow sections also written in C).
Features from 2.4.x will be used, with no regard for compatibility with past versions.
Travis CI verifies that everything continues to work with 2.4.x.
It additionally shows which problems do and do not work with 2.3.x.

# Input

In general, all solutions can be invoked in both of the following ways:

* Without command-line arguments, takes input on standard input.
* With command-line arguments, reads input from the named files (- indicates standard input).

Some may additionally support other ways:

* 3 (Spiral Matrix): Pass the input in ARGV.
* 14 (Disk Defrag): Pass the input in ARGV.
* 15 (Dueling Generators): Pass the seeds in ARGV.
* 17 (Spinlock): Pass the step size in ARGV.

# Highlights

Solutions with interesting algorithmic choices:

* 13 (Packet Scanners):
  For each period: look at starting times forbidden by scanners of that period.
  Combine those, especially any periods that only admit one starting time.
  e.g. for my solution:
  * Congruent to 966862 mod 1441440
  * Congruent to some number in [0, 2, 6, 8, 10, 12, 16, 18, 20, 22, 24, 26, 28, 30, 32] mod 34
* 16 (Permutation Promenade):
  * Not my idea; instead is currently the [top-rated comment](https://www.reddit.com/r/adventofcode/comments/7k572l/2017_day_16_solutions/drbqb27/) on the Reddit thread.
    Separate the permutations and substitutions.
    Use exponentiation by squaring to apply both the requisite number of times.
  * Alternative idea: Find a cycle.
* 17 (Spinlock):
  Everyone probably figured this one out: 0 is always the first element, so we only track elements that insert right after it.
  Extra step: Note that if the spinlock is sufficiently far away from the right end of the buffer, we can take multiple steps before it wraps.
  Using this fact, we can avoid taking as many moduli.
  From time to time I also see other solutions using the exact name `fits` for this.
* 21 (Fractal Art):
  Mostly explained in comments; the board can be decomposed into independent sub-boards that develop independently of one another.
  Thus, we can simply keep track of how many of each sub-board there are.
  I believe the enhancement process is linear time, but we start taking quadratic time on exceptionally large numbers of iterations because of repeatedly adding BigNums together.
  As explained in the current [top-rated comment](https://www.reddit.com/r/adventofcode/comments/7l78eb/2017_day_21_solutions/drks1g2/), one would be able to improve on this by using exponentiation by squaring for cycle counts divisible by 3.
* 24 (Dominoes):
  A few ideas can be found in the [can it be done more efficiently?](https://www.reddit.com/r/adventofcode/comments/7lunzu/2017_day_24_so_can_it_be_done_more_efficiently/) thread.
  The only one I needed to use was the one that optimises out any `[X, X]` dominoes.
  There are only 6 `[X, X]` dominoes in my input of 57, but this decreases the number of bridges found from 288414 to 21783.

Solutions notable for good leaderboard-related reasons:

* 7 (Balancing Discs):
  [So close](http://adventofcode.com/2017/leaderboard/day/7)!!!
* 18 (Duet):
  Solution ends up not being very complicated, but is fun to explore options for concurrency, regardless of whether the implementation actually runs things in parallel.
* 20 (Particle Swarm):
  Probably [my best overall performance](http://adventofcode.com/2017/leaderboard/day/20)?

Solutions notable for bad leaderboard-related reasons:

* 3 (Spiral Matrix) part 1:
  Panicked and thought about attempting to math out the answer. Abandoned the attempt after a few minutes and just filled in the matrix step by step.
* 5 (CPU Jump):
  Got careless with the exact sequence of operations: Jump with offset equal to current value, then increase value you were previously at.
  Resulted in at least two obviously wrong implementations:
  * increase new value you land on
  * increase value you are currently at, then jump with offset equal to that new value.
* 10 (Knot Hash) part 2:
  Careless with converting values < 16.
  Didn't bother checking that resulting values are exactly 32 characters.
  Then, used `ljust` instead of correct `rjust`, making 10 turn into `a0` instead of `0a`.
  `'%02x' % nibble` would have been less error-prone.
* 13 (Packet Scanners):
  Inadvisably kept track of the position/direction of every scanner at every tick.
  For the problem, we only need to know whether it is at position 0 and do not care about anything else.
* 14 (Disk Defrag) part 2:
  Used my usual `[-1, 0, 1].flat_map { |dy| [-1, 0, 1].map { |dx| ... } }` and only when I printed out the resulting groups did I realise that this improperly included diagonals.
  I don't think I have a better way to express orthogonals than `[[-1, 0], [1, 0], [0, -1], [0, 1]].map { |dy, dx| ... }`, just have to make sure I use the right one.
* 16 (Permutation Promenade) part 2:
  Assumed the right approach was to apply permutation from one iteration 1 billion times, even converting the program to Crystal and waiting ~minutes for it to give a result, only for it to be wrong.
  Failed to realise, of course, that we have to consider the permutations and substitutions separately.
  Ended up looking for a cycle to get the answer.
* 19 (Routing Diagram):
  Code got terribly confused and started repeating part of the path (e.g. ABCDEFCBA).
  I was able to submit only the non-repeating letters as my answer, but then had to actually confirm that the path ended exactly at the last letter (and no further) before being able to make part 2.
  Perhaps could have just assumed it would and submitted a quick guess.
* 20 (Particle Swarm):
  Input parser ignored negative signs, and I assumed a correct part 1 answer meant my input parsing was correct.
  Had it not been for this error, probably could have taken 1/1 given my significant lead over anyone else on part 1.
* 21 (Fractal Art):
  Reading comprehension failure: Conveniently forgot that twos take precedence over threes, simply because I coded up threes first.
  The starting input, after all, falls under the threes category!
* 22 (Sporifica Virus):
  Massive failure in keeping directions straight (using complex numbers at the time).
  I knew that up was -i and right was +1, but attempted to do all my left/right math starting from up because that's the direction you start pointing at.
  So I thought "I start at up, that's -i, now if I want to be moving left, that's -1, so what do I multiply by -i to get -1" and got too confused by negative signs.
  The smart thing to do would have been "If I'm facing right, that's +1. If I want to turn left, that's up which is -i, so obviously left is -i and right is +i".
  Worse, I thought my wrong direction was correct simply because that was what I used in 2016 day 1, but in 2016 day 1 it doesn't matter whether up is +y or -y (and I chose +y, the opposite convention), but here it does matter since it needs to match the convention of the input!
  This significantly delayed my detection of the error, which I could have figured out if I had been a little more practiced with the math.
* 23 (Coprocessor Conflagration):
  Hindsight is 20/20.
  How did it take ~35 minutes to understand what that program was doing?
* 24 (Dominoes):
  Tried to take a cheap shot (take all pairs of numbers until there are no pairs left, then add the largest remaining number), which obviously failed because not all dominoes are used in the final bridge.
* 25 (Turing Machine):
  I actually went and parsed the input because I was too afraid that I would screw it up if I tried to enter in everything by hand.
  I regret nothing!
  I think...?

# Posting schedule and policy

Before I post my day N solution, the day N leaderboard **must** be full.
No exceptions.

Waiting any longer than that seems generally not useful since at that time discussion starts on [the subreddit](https://www.reddit.com/r/adventofcode) anyway.

Solutions posted will be **cleaned-up** versions of code I use to get leaderboard times (if I even succeed in getting them), rather than the exact code used.
This is because leaderboard-seeking code is written for programmer speed (whatever I can come up with in the heat of the moment).
This often produces code that does not meet any of the goals of this repository (seen in the introductory paragraph).

# Past solutions

The [index](https://github.com/petertseng/adventofcode-common/blob/master/index.md) lists all years/languages I've ever done (or will ever do).
