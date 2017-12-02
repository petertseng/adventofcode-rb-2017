rows = ARGF.map { |l| l.split.map(&method(:Integer)).freeze }.freeze

puts rows.sum { |r| -r.minmax.reduce(:-) }

puts rows.sum { |r| r.permutation(2).find { |a, b| a % b == 0 }.reduce(:/) }
