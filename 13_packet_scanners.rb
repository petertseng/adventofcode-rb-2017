depths = ARGF.to_h { |x|
  x.scan(/\d+/).map(&method(:Integer)).freeze
}.freeze

periods = depths.to_h { |k, v| [k, 2 * (v - 1)] }.freeze

puts periods.select { |k, v| k % v == 0 }.keys.sum { |k| k * depths[k] }

puts 0.step.find { |delay|
  periods.all? { |k, v| (k + delay) % v != 0 }
}
