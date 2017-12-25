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

loops = {}

STATES.each_with_index.to_a.combination(2) { |(va, ka), (vb, kb)|
  [0, 1].each { |bit|
    write_a, move_a, next_a = va[bit]
    write_b, move_b, next_b = vb[bit]
    if move_a == move_b && next_a == kb && next_b == ka
      write = [write_a, write_b]
      loops[[ka, bit]] = [write.freeze, move_a, kb].freeze
      loops[[kb, bit]] = [write.reverse.freeze, move_b, ka].freeze
    end
  }
}

ticker = [0] * (check_after ** 0.5).ceil * 2
pos = ticker.size / 2
n = 0

while n < check_after
  current = ticker[pos] || 0.tap { ticker.concat([0] * ticker.size) }
  if (cycle, move, other = loops[[state, current]])
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

puts ticker.sum
