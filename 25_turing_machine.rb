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

# I'll not use the entire word; in Ruby 2.3 1 << 62 is Bignum.
BLOCK_SIZE = 0.size * 8 - 3

ticker = [0] * ((check_after ** 0.5).ceil * 2 / BLOCK_SIZE)

pos = ticker.size * BLOCK_SIZE / 2
block_i, block_pos = pos.divmod(BLOCK_SIZE)
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
    block_pos += BLOCK_SIZE
    block_i -= 1
    if block_i == -1
      block_i += ticker.size
      ticker.unshift(*[0] * ticker.size)
    end
    block = ticker[block_i]
  elsif block_pos == BLOCK_SIZE
    ticker[block_i] = block
    block_pos = 0
    block_i += 1
    ticker.concat([0] * ticker.size) if block_i == ticker.size
    block = ticker[block_i]
  end
}

ticker[block_i] = block

puts ticker.sum { |x| x.digits(2).count(1) }
