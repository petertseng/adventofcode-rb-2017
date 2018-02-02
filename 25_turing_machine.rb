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

# Experimentally, this gave a good runtime,
# but didn't investigate to explain why this is good.
# I suppose performance gets worse at 63 because some numbers become bigints,
# such as new_bit << block_pos
BLOCK_SIZE = 62

CACHE = {}
def run_block(left, right, state, steps_left)
  pos = BLOCK_SIZE
  steps_taken = 0
  # Leftmost bit of left doesn't matter.
  left &= ~1
  cache_key = [left, right, state].freeze
  if (cached = CACHE[cache_key]) && cached[-1] <= steps_left
    return cached
  end

  while steps_taken < steps_left && (1...(2 * BLOCK_SIZE)).cover?(pos)
    block_i, block_pos = pos.divmod(BLOCK_SIZE)
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
  CACHE[cache_key] = [left, right, state, pos == 0 ? -1 : 1, steps_taken].freeze
end

ticker = [0] * [(check_after ** 0.5) * 4 / BLOCK_SIZE, 2].max
pos = ticker.size / 2
steps_left = check_after

while steps_left > 0
  new_left, new_right, state, where_to_go, steps_taken = run_block(
    ticker[pos - 1],
    ticker[pos] || 0.tap { ticker.concat([0] * ticker.size) },
    state, steps_left,
  )
  steps_left -= steps_taken
  ticker[pos - 1] = (ticker[pos - 1] & 1) | (new_left & ~1)
  ticker[pos] = new_right
  pos += where_to_go
  if pos < 0
    pos += ticker.size
    ticker.unshift(*[0] * ticker.size)
  end
end

puts ticker.sum { |t| t.to_s(2).count(?1) }
