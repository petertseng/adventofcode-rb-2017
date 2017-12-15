MOD = 2 ** 31 - 1

A, B = if ARGV.size >= 2 && ARGV.all? { |arg| arg.match?(/^\d+$/) }
  ARGV
else
  ARGF.read.scan(/\d+/)
end.map(&method(:Integer))
AM = 16807
BM = 48271

# Unfortunately, I will have to use c = 0, c += 1, puts c
# rather than puts N.times.count {},
# it brings from 10.5 seconds to 9.5.

a = A
b = B
c = 0

40_000_000.times {
  a = a * AM % MOD
  b = b * BM % MOD
  c += 1 if a & 0xffff == b & 0xffff
}
puts c

a = A
b = B
c = 0

5_000_000.times {
  a = a * AM % MOD
  a = a * AM % MOD until a % 4 == 0
  b = b * BM % MOD
  b = b * BM % MOD until b % 8 == 0
  c += 1 if a & 0xffff == b & 0xffff
}
puts c
