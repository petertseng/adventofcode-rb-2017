MOD = 2 ** 31 - 1

A, B = if ARGV.size >= 2 && ARGV.all? { |arg| arg.match?(/^\d+$/) }
  ARGV
else
  ARGF.read.scan(/\d+/)
end.map(&method(:Integer))
AM = 16807
BM = 48271

c_lib = File.join(__dir__, 'c', 'lib15.so')
if File.exist?(c_lib)
  require 'fiddle'

  lib = Fiddle.dlopen(c_lib)
  ['part1', 'part2'].map { |f| Fiddle::Function.new(
    lib[f], [Fiddle::TYPE_LONG_LONG] * 2, Fiddle::TYPE_LONG_LONG,
  )}.each { |f| puts f.call(A, B) }

  exit 0
end

# Unfortunately, I will have to use c = 0, c += 1, puts c
# rather than puts N.times.count {},
# it brings from 10.5 seconds to 9.5.

a = A
b = B
c = 0

5_000_000.times {
  # And in a desperate bid to cut runtime,
  # we are doing loop unrolling, very sad.
  # Since this is the single day that takes the longest time,
  # it is unfortunately necessary.
  # 1x: 9.5 seconds
  # 2x: 9.2 seconds
  # 4x: 8.7 seconds
  # 8x: 8.4 seconds
  # 16x: 8.4 seconds
  # So we stay with 8x.
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
}
puts c

a = A
b = B
c = 0

5_000_000.times {
  # Loop unrolling here doesn't seem to help much.
  a = a * AM % MOD
  a = a * AM % MOD until a % 4 == 0
  b = b * BM % MOD
  b = b * BM % MOD until b % 8 == 0
  c += 1 if a & 0xffff == b & 0xffff
}
puts c
