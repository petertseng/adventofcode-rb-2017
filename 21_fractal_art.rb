VERBOSE = ARGV.delete('-v')
ITERS = if (narg = ARGV.find { |a| a.start_with?('-n') })
  ARGV.delete(narg)
  narg[2..-1].split(?,).map(&method(:Integer))
else
  [5, 13]
end.freeze

rules = ARGF.map(&:chomp).freeze

# Base rules (those given in input)
bit = {?# => true, ?. => false}.freeze
rules_by_size = rules.map { |rul|
  rul.split('=>').map { |slashed|
    slashed.strip.split(?/).map { |rl| rl.chars.map { |c| bit.fetch(c) } }
  }
}.group_by { |l, _| l.size }.transform_values { |vs|
  vs.flat_map { |l, r|
    rotations = [l, l.map(&:reverse)]
    # transpose -> map(&:reverse) = rotate by 90
    6.times { rotations << rotations[-2].transpose.map(&:reverse) }
    rotations.map { |rot| [rot.flatten, r.flatten] }
  }.to_h.freeze
}.freeze

# This problem is solvable only using the base rules,
# if we explicitly keep the grid and translate to/from the flat form.
# However, to be more efficient, let's exploit the repeating substructure.
# We start with a 3x3 grid.
#
# Then the grid size follows a cycle of size 3:
# n =     3^k     -> 3 -> 4 rule -> 4 * 3^(k-1)           (even)
# n = 4 * 3^(k-1) -> 2 -> 3 rule -> 6 * 3^(k-1) = 2 * 3^k (even)
# n = 2 * 3^k     -> 2 -> 3 rule -> 3 * 3^k     = 3^(k+1) (odd)
# Cycle repeats, and that point every resulting 3x3 subgrid develops independently of the others!
# That means we only need to keep track of how many of each subgrid there are.
#
# To support the cycle, we need to map:
# 9 -> [16] * 1, 16 -> [4] * 9, 4 -> [9] * 1
#
# Why doesn't it work to map 9 -> [4] * 4?
# Because we need the relative positions of the resulting 3x3
# in order to be able to create the [4] * 9 grid.
# If we simply mapped to [4] * 4,
# we would lose the position information.
#
# We could go faster with a matrix of 3x3 -> 3x3 counts every 3 iterations,
# and then exponentiate by squaring, but no motivation to write that code.

# Instead of storing arrays of bits, we'll compress them into a single integer.
# This should avoid allocating so many arrays.
def compress(grid)
  # Max number of bits is 16.
  # To disambiguate between grids of different sizes,
  # we'll also store the size starting at the 16th bit.
  (grid.size << 16) | grid.flatten.reduce(0) { |acc, bit| acc << 1 | (bit ? 1 : 0) }
end

# key: 4x4 subgrid
# value: list of nine 2x2 subgrids resulting from the key
rules_16_36 = rules_by_size[3].values.map { |sixteen|
  subgrids = [0, 2, 8, 10].map { |i|
    rules_by_size[2].fetch(sixteen.values_at(*[0, 1, 4, 5].map { |j| i + j }))
  }
  # subgrids:
  # 0 | 1
  # -----
  # 2 | 3
  #
  # within each subgrid:
  # 0 1 2
  # 3 4 5
  # 6 7 8

  in_one_subgrid = ->(subgrid, upper_left) {
    [
      [subgrid, upper_left],
      [subgrid, upper_left + 1],
      [subgrid, upper_left + 3],
      [subgrid, upper_left + 4],
    ]
  }

  two_by_twos = [
    in_one_subgrid[0, 0],
    [[0, 2], [1, 0], [0, 5], [1, 3]],
    in_one_subgrid[1, 1],
    [[0, 6], [0, 7], [2, 0], [2, 1]],
    [[0, 8], [1, 6], [2, 2], [3, 0]],
    [[1, 7], [1, 8], [3, 1], [3, 2]],
    in_one_subgrid[2, 3],
    [[2, 5], [3, 3], [2, 8], [3, 6]],
    in_one_subgrid[3, 4],
  ]

  [compress(sixteen), two_by_twos.map { |coords|
    compress(coords.map { |cs| subgrids.dig(*cs) })
  }.freeze]
}.to_h

# key: any subgrid (might be 4x4, 3x3, 2x2)
# value: the list of subgrids resulting from the key
# note that if the key is K, value is V:
# K = 4x4, V = array of nine 2x2 (from rules_16_36)
# K = 3x3, V = array of  one 4x4 (from rules_by_size[3])
# K = 2x2, V = array of  one 3x3 (from rules_by_size[2])
complex_rules = (rules_by_size[2].merge(rules_by_size[3])).map { |k, v|
  [compress(k), [compress(v)].freeze]
}.to_h.merge(rules_16_36).freeze

grid = {
  compress([false, true, false, false, false, true, true, true, true]) => 1,
}.freeze

ITERS.each { |times|
  times.times { |n|
    output_grid = Hash.new(0)

    grid.each { |subgrid, cardinality|
      complex_rules.fetch(subgrid).each { |new_subgrid|
        output_grid[new_subgrid] += cardinality
      }
    }

    grid = output_grid.freeze
  }
  puts grid.sum { |subgrid, cardinality|
    subgrid.digits(2).take(16).count(1) * cardinality
  }
}
