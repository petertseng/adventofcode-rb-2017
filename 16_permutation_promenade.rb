NLETTERS = if (narg = ARGV.find { |a| a.start_with?('-n') })
  ARGV.delete(narg)
  Integer(narg[2..-1])
else
  16
end

# Simply finding a single permutation matrix after one iteration is insufficient,
# since there are both absolute and relative movements.
# Two possible strategies:
# 1. Find cycle length, dance 1_000_000_000 modulo cycle_length times.
# 2. Separate the absolute and relative movements.
#    Applying them separately gives the same result as applying them interleaved.
#    Repeatedly applying them to themselves tells what happens if you apply them 2**n times.

def moves(steps)
  relative_moves = (0...NLETTERS).to_a
  absolute_moves = (?a..?z).take(NLETTERS).join

  steps.each { |step|
    args = step[1..-1]
    case step[0]
    when ?s
      relative_moves.rotate!(-Integer(args))
    when ?x
      l, r = args.scan(/\d+/).map(&:to_i)
      relative_moves[l], relative_moves[r] = relative_moves.values_at(r, l)
    when ?p
      l, r = args.split(?/)
      absolute_moves.tr!(l + r, r + l)
    else raise "Unknown dance step #{step}"
    end
  }

  [relative_moves, absolute_moves]
end

def dance(relative_moves, absolute_moves, n)
  orig = (?a..?z).take(NLETTERS).join.freeze

  n.digits(2).reduce(orig.dup) { |progs, bit|
    if bit == 1
      progs.tr!(orig, absolute_moves)
      progs = Array.new(NLETTERS) { |i| progs[relative_moves[i]] }.join
    end

    relative_moves = relative_moves.map { |r| relative_moves[r] }
    absolute_moves = absolute_moves.tr(orig, absolute_moves)

    progs
  }
end

moves = moves(ARGF.read.chomp.split(?,)).map(&:freeze).freeze

puts dance(*moves, 1)
puts dance(*moves, 1_000_000_000)
