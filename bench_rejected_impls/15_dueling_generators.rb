require 'benchmark'

MOD = 2 ** 31 - 1

bench_candidates = []

NTIMES = 40_000

bench_candidates << def ntimes
  a = A
  b = B
  c = 0

  NTIMES.times {
    a = a * AM % MOD
    b = b * BM % MOD
    c += 1 if a & 0xffff == b & 0xffff
  }
  c
end

def gen(v0, multiplier)
  Enumerator.produce(v0) { |v| v * multiplier % MOD }.lazy
end

bench_candidates << def produce
  nums = gen(A, AM).zip(gen(B, BM))
  nums.next
  c = 0

  i = 0
  while (i += 1) < NTIMES
    a, b = nums.next
    c += 1 if a & 0xffff == b & 0xffff
  end
  c
end

bench_candidates << def while_loop
  a = A
  b = B
  c = 0

  i = 0
  while (i += 1) < NTIMES
    a = a * AM % MOD
    b = b * BM % MOD
    c += 1 if a & 0xffff == b & 0xffff
  end
  c
end

bench_candidates << def unroll2
  a = A
  b = B
  c = 0

  i = 0
  while (i += 2) < NTIMES
    a = a * AM % MOD
    b = b * BM % MOD
    c += 1 if a & 0xffff == b & 0xffff
    a = a * AM % MOD
    b = b * BM % MOD
    c += 1 if a & 0xffff == b & 0xffff
  end
  c
end

bench_candidates << def unroll4
  a = A
  b = B
  c = 0

  i = 0
  while (i += 4) < NTIMES
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
  end
  c
end

bench_candidates << def unroll8
  a = A
  b = B
  c = 0

  i = 0
  while (i += 8) < NTIMES
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
  end
  c
end

bench_candidates << def unroll16
  a = A
  b = B
  c = 0

  i = 0
  while (i += 16) < NTIMES
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
  end
  c
end

bench_candidates << def unroll32
  a = A
  b = B
  c = 0

  i = 0
  while (i += 32) < NTIMES
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
  end
  c
end

bench_candidates << def count
  a = A
  b = B

  NTIMES.times.count {
    a = a * AM % MOD
    b = b * BM % MOD
    a & 0xffff == b & 0xffff
  }
end

A, B = if ARGV.size >= 2 && ARGV.all? { |arg| arg.match?(/^\d+$/) }
  ARGV
else
  ARGF.read.scan(/\d+/)
end.map(&method(:Integer))
AM = 16807
BM = 48271

results = {}

Benchmark.bmbm { |bm|
  bench_candidates.each { |f|
    bm.report(f) { 10.times { results[f] = send(f) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end
