def match(input, dist:)
  # Doesn't matter whether we go forward or backward,
  # (either way we get a yes on one half of the matching pair)
  # so let's go backward to take advantage of negative index.
  input.each_char.select.with_index { |c, i| c == input[i - dist] }.sum(&method(:Integer))
end

input = (!ARGV.empty? && ARGV.first.match?(/^\d+$/) ? ARGV.first : ARGF.read).chomp.freeze

[1, input.size / 2].each { |n| puts match(input, dist: n) }
