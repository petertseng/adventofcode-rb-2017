require 'benchmark'

bench_candidates = []
slow_bench_candidates = []

[32, 40, 48, 56, 59, 60, 61, 62, 63, 64, 128].each { |blocksize|
  bench_candidates << define_method("cache_by_block#{blocksize}") { |state, check_after|
    cache = {}
    run_block = ->(left, right, state, steps_left) {
      pos = blocksize
      steps_taken = 0
      # Leftmost bit of left doesn't matter.
      left &= ~1
      cache_key = [left, right, state].freeze
      if (cached = cache[cache_key]) && cached[-1] <= steps_left
        return cached
      end

      while steps_taken < steps_left && (1...(2 * blocksize)).cover?(pos)
        block_i, block_pos = pos.divmod(blocksize)
        current_bit = (block_i == 0 ? left : right)[block_pos]
        new_bit, where_to_go, state = STATES[state][current_bit]
        if current_bit != new_bit
          mask = ~(1 << block_pos)
          if block_i == 0
            left = (left & mask) | (new_bit << block_pos)
          else
            right = (right & mask) | (new_bit << block_pos)
          end
        end
        pos += where_to_go
        steps_taken += 1
      end
      cache[cache_key] = [left, right, state, pos == 0 ? -1 : 1, steps_taken].freeze
    }

    ticker = [0] * [(check_after ** 0.5) * 4 / blocksize, 2].max
    pos = ticker.size / 2
    steps_left = check_after

    while steps_left > 0
      new_left, new_right, state, where_to_go, steps_taken = run_block[
        ticker[pos - 1],
        ticker[pos] || 0.tap { ticker.concat([0] * ticker.size) },
        state, steps_left,
      ]
      steps_left -= steps_taken
      ticker[pos - 1] = (ticker[pos - 1] & 1) | (new_left & ~1)
      ticker[pos] = new_right
      pos += where_to_go
      if pos < 0
        pos += ticker.size
        ticker.unshift(*[0] * ticker.size)
      end
    end

    ticker.sum { |t| t.to_s(2).count(?1) }
  }
}

# slower because it reads/writes 7 elements for every 4 cycles,
# rather than 1:1
slow_bench_candidates << def by_4_iters(orig_state, check_after)
  block_size = 7
  block_radius = block_size / 2

  cache = (0...(2 ** block_size)).each_with_object({}) { |x, c|
    bits = (0...block_size).map { |bit_i| x & (1 << (block_size - 1 - bit_i)) != 0 ? 1 : 0 }
    STATES.each_index { |start_state|
      state = start_state
      ticker = bits.dup
      pos = block_radius
      (block_radius + 1).times {
        ticker[pos], where_to_go, state = STATES[state][ticker[pos]]
        pos += where_to_go
      }
      raise 'conflict' if c.has_key?(start_state << block_size | x)
      c[start_state << block_size | x] = [state, ticker.freeze, pos - block_radius].freeze
    }
  }.freeze

  state = orig_state
  ticker = [0] * (check_after ** 0.5).ceil * 2
  pos = ticker.size / 2

  (check_after / (block_radius + 1)).times {
    x = (-block_radius..block_radius).reduce(0) { |acc, dp| acc << 1 | (
      ticker[pos + dp] || 0.tap { ticker.concat([0] * ticker.size) }
    )}
    state, new_bits, delta_pos = cache[state << block_size | x]
    if pos - block_radius < 0
      pos += ticker.size
      ticker.unshift(*[0] * ticker.size)
    end
    ticker[pos - block_radius, block_size] = new_bits
    pos += delta_pos
  }

  ticker.sum
end

slow_bench_candidates << def block_by_ints(state, check_after)
  # I'll not use the entire word; in Ruby 2.3 1 << 62 is Bignum.
  block_size = 0.size * 8 - 3

  ticker = [0] * ((check_after ** 0.5).ceil * 2 / block_size)

  pos = ticker.size * block_size / 2
  block_i, block_pos = pos.divmod(block_size)
  block = 0

  check_after.times {
    bit = 1 << block_pos

    write, where_to_go, state = STATES[state][block[block_pos]]
    if write == 0
      block &= ~bit
    else
      block |= bit
    end

    block_pos += where_to_go
    if block_pos < 0
      ticker[block_i] = block
      block_pos += block_size
      block_i -= 1
      if block_i == -1
        block_i += ticker.size
        ticker.unshift(*[0] * ticker.size)
      end
      block = ticker[block_i]
    elsif block_pos == block_size
      ticker[block_i] = block
      block_pos = 0
      block_i += 1
      ticker.concat([0] * ticker.size) if block_i == ticker.size
      block = ticker[block_i]
    end
  }

  ticker[block_i] = block

  ticker.sum { |x| x.digits(2).count(1) }
end

slow_bench_candidates << def loops(state, check_after)
  loops = []

  STATES.each_with_index.to_a.combination(2) { |(va, ka), (vb, kb)|
    [0, 1].each { |bit|
      write_a, move_a, next_a = va[bit]
      write_b, move_b, next_b = vb[bit]
      if move_a == move_b && next_a == kb && next_b == ka
        write = [write_a, write_b]
        loops[ka << 1 | bit] = [write.freeze, move_a, kb].freeze
        loops[kb << 1 | bit] = [write.reverse.freeze, move_b, ka].freeze
      end
    }
  }

  loops.freeze

  ticker = [0] * (check_after ** 0.5).ceil * 2
  pos = ticker.size / 2
  n = 0

  while n < check_after
    current = ticker[pos] || 0.tap { ticker.concat([0] * ticker.size) }
    if (cycle, move, other = loops[state << 1 | current])
      original_pos = pos
      original_n = n
      while n < check_after && ticker[pos] == current
        pos += move
        if pos == -1
          pos += ticker.size
          ticker.unshift(*[0] * ticker.size)
        end
        n += 1
      end
      dist = n - original_n
      left = move > 0 ? original_pos : pos + 1
      writes = cycle.cycle.take(dist)
      writes.reverse! if move < 0
      state = other if dist.odd?
      ticker[left, dist] = writes
      next
    end
    ticker[pos], where_to_go, state = STATES[state][current]
    pos += where_to_go
    if pos < 0
      pos += ticker.size
      ticker.unshift(*[0] * ticker.size)
    end
    n += 1
  end

  ticker.sum
end

# With 15065428 scans, saved 12919240 iterations.
slow_bench_candidates << def neighbours(orig_state, check_after)
  block_size = 7
  block_radius = block_size / 2

  cache = (0...(2 ** block_size)).each_with_object({}) { |x, c|
    bits = (0...block_size).map { |bit_i| x & (1 << (block_size - 1 - bit_i)) != 0 ? 1 : 0 }
    STATES.each_index { |start_state|
      n = 0
      state = start_state
      ticker = bits.dup
      pos = block_radius
      while pos >= 0 && (current = ticker[pos])
        ticker[pos], where_to_go, state = STATES[state][current]
        pos += where_to_go
        n += 1
      end
      raise 'conflict' if c.has_key?(start_state << block_size | x)
      c[start_state << block_size | x] = [state, ticker.freeze, pos - block_radius, n].freeze
    }
  }.freeze

  state = orig_state
  ticker = [0] * (check_after ** 0.5).ceil * 2
  pos = ticker.size / 2
  n = 0

  #scans = 0
  #saves = 0

  while n < check_after
    x = (-block_radius..block_radius).reduce(0) { |acc, dp| acc << 1 | (
      ticker[pos + dp] || 0.tap { ticker.concat([0] * ticker.size) }
    )}
    new_state, new_bits, delta_pos, delta_n = cache[state << block_size | x]
    if n + delta_n < check_after
      ticker[pos - block_radius, block_size] = new_bits
      pos += delta_pos
      n += delta_n
      #scans += block_size
      #saves += delta_n
      state = new_state
    else
      ticker[pos], where_to_go, state = STATES[state][ticker[pos]]
      pos += where_to_go
      n += 1
    end

    if pos - block_radius < 0
      pos += ticker.size
      ticker.unshift(*[0] * ticker.size)
    end
  end

  ticker.sum
end

slow_bench_candidates << def hash_of_ones(state, check_after)
  ones = {}
  pos = 0

  check_after.times {
    write, where_to_go, state = STATES[state][ones.has_key?(pos) ? 1 : 0]
    if write == 1
      ones[pos] = true
    else
      ones.delete(pos)
    end
    pos += where_to_go
  }

  ones.size
end

def parse_input(input)
  input.each("\n\n", chomp: true).map.with_index { |state, i|
    lines = state.lines
    parsing_state = parse_state(lines.shift)
    # Assume input comes in order.
    raise "parsing #{parsing_state}, wanted #{states.size}" if parsing_state != i
    2.times.map { |i|
      # Assume input comes in order.
      parse_rule(i, lines.shift(4))
    }.freeze
  }.freeze
end

def parse_rule(expect, input)
  zero_or_one = ->(s) { Integer(s[/\d+/]).tap { |i|
    raise "bad #{i}, must be 0 or 1" unless i == 0 || i == 1
  }}

  current = zero_or_one[input.shift]
  raise "unexpected #{current}, wanted #{expect}" if current != expect
  write = zero_or_one[input.shift]
  move = (dir = input.shift).include?('right') ? 1 : dir.include?('left') ? -1 : (raise "bad move #{dir}")
  state = parse_state(input.shift)

  [write, move, state].freeze
end

def parse_state(line)
  line.chomp[-2].ord - ?A.ord
end

state = parse_state(ARGF.readline)
check_after = Integer(ARGF.readline[/\d+/])
unless (empty = ARGF.readline).chomp.empty?
  raise "#{empty} should have been empty"
end
STATES = parse_input(ARGF)

results = {}

Benchmark.bmbm { |bm|
  bench_candidates.each { |f|
    bm.report(f) { 10.times { results[f] = send(f, state, check_after) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end

puts "slow (only run 1x instead of 10x!)"

Benchmark.bmbm { |bm|
  slow_bench_candidates.each { |f|
    bm.report(f) { 1.times { results[f] = send(f, state, check_after) } }
  }
}

# Obviously the benchmark would be useless if they got different answers.
if results.values.uniq.size != 1
  results.each { |k, v| puts "#{k} #{v}" }
  raise 'differing answers'
end
