part_2_only = ARGV.delete('-2')

def twist(lengths, n)
  pos = 0
  skip_size = 0

  n.times.with_object((0..255).to_a) { |_, l|
    lengths.each { |len|
      l.rotate!(pos)
      l[0, len] = l[0, len].reverse
      l.rotate!(-pos)
      pos += len + skip_size
      skip_size += 1
    }
  }
end

input = (!ARGV.empty? && ARGV.first.include?(?,) ? ARGV.first : ARGF.read).chomp.freeze

puts twist(input.split(?,).map(&method(:Integer)), 1).take(2).reduce(:*) unless part_2_only

puts twist(input.bytes + [17, 31, 73, 47, 23], 64).each_slice(16).map { |byte|
  byte.reduce(0, :^).to_s(16).rjust(2, ?0)
}.join
