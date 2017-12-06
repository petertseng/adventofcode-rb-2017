input = (!ARGV.empty? && ARGV.all? { |a| a.match?(/^\d+$/) } ? ARGV : ARGF.read).split.map(&method(:Integer))

seen = {input.dup.freeze => 0}
puts 1.step { |n|
  max = input.max
  start = input.index(max)
  input[start] = 0
  max.times { |i| input[(start + 1 + i) % input.size] += 1 }
  break [n, n - seen[input]] if seen.has_key?(input)
  seen[input.dup.freeze] = n
}
