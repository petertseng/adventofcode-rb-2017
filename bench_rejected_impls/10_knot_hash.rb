require_relative '../lib/search'
require_relative '../lib/union_find'

require 'benchmark'

bench_candidates = []

bench_candidates << def immed_rot(lengths, n)
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

bench_candidates << def defer_rot(lengths, n)
  pos = 0
  skip_size = 0
  deferred_rotate = 0

  n.times.with_object((0..255).to_a) { |_, l|
    lengths.each { |len|
      l.rotate!(pos + deferred_rotate)
      l[0, len] = l[0, len].reverse
      # We would rotate by -pos here,
      # but defer it until the next so we do fewer rotates.
      deferred_rotate = -pos
      pos += len + skip_size
      skip_size += 1
    }
  }.rotate!(deferred_rotate)
end

bench_candidates << def no_rot(lengths, n)
  pos = 0
  skip_size = 0

  n.times.with_object((0..255).to_a) { |_, l|
    lengths.each { |len|
      if pos + len <= 256
        l[pos, len] = l[pos, len].reverse
      else
        right_len = 256 - pos
        left_len = len - right_len
        elts = l[pos, right_len] + l[0, left_len]
        elts.reverse!
        l[pos, right_len] = elts[0, right_len]
        l[0, left_len] = elts[right_len, left_len]
      end
      pos += len + skip_size
      pos %= 256
      skip_size += 1
    }
  }
end

input = (!ARGV.empty? && ARGV.first.include?(?,) ? ARGV.first : ARGF.read).chomp.freeze

results = {}

Benchmark.bmbm { |bm|
  bench_candidates.each { |f|
    bm.report(f) { 100.times { results[f] = send(f, input.bytes + [17, 31, 73, 47, 23], 64) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end
