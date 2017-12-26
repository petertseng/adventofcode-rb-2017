def parse_input(input)
  states = []

  until input.empty?
    raise 'discarded non-empty line' unless input.shift.strip.empty?

    parsing_state = parse_state(input.shift)
    # Assume input comes in order.
    raise "parsing #{parsing_state}, wanted #{states.size}" if parsing_state != states.size
    states << 2.times.map { |i|
      # Assume input comes in order.
      parse_rule(i, input.shift(4))
    }.freeze
  end

  states.freeze
end

def parse_rule(expect, input)
  zero_or_one = ->(s) { Integer(s[/\d+/]).tap { |i|
    raise "bad #{i}, must be 0 or 1" unless i == 0 || i == 1
  }}

  current = zero_or_one[input.shift]
  raise "unexpected #{current}, wanted #{expect}" if current != expect
  write = zero_or_one[input.shift]
  move = input.shift.include?('right') ? 1 : -1
  state = parse_state(input.shift)

  [write, move, state].freeze
end

def parse_state(line)
  line.chomp[-2].ord - ?A.ord
end

input = ARGF.readlines

state = parse_state(input.shift)
check_after = Integer(input.shift[/\d+/])
STATES = parse_input(input)

BLOCK_SIZE = 7
BLOCK_RADIUS = BLOCK_SIZE / 2

def fill_cache
  cache = {}

  (0...(2 ** BLOCK_SIZE)).each { |x|
    bits = (0...BLOCK_SIZE).map { |bit_i| x & (1 << (BLOCK_SIZE - 1 - bit_i)) != 0 ? 1 : 0 }
    STATES.each_index { |start_state|
      state = start_state
      ticker = bits.dup
      pos = BLOCK_RADIUS
      (BLOCK_RADIUS + 1).times {
        ticker[pos], where_to_go, state = STATES[state][ticker[pos]]
        pos += where_to_go
      }
      raise 'conflict' if cache.has_key?(start_state << BLOCK_SIZE | x)
      cache[start_state << BLOCK_SIZE | x] = [state, ticker.freeze, pos - BLOCK_RADIUS].freeze
    }
  }

  cache.freeze
end

cache = fill_cache

ticker = [0] * (check_after ** 0.5).ceil * 2
pos = ticker.size / 2

(check_after / (BLOCK_RADIUS + 1)).times {
  x = (-BLOCK_RADIUS..BLOCK_RADIUS).reduce(0) { |acc, dp| acc << 1 | (
    ticker[pos + dp] || 0.tap { ticker.concat([0] * ticker.size) }
  )}
  state, new_bits, delta_pos = cache[state << BLOCK_SIZE | x]
  if pos - BLOCK_RADIUS < 0
    pos += ticker.size
    ticker.unshift(*[0] * ticker.size)
  end
  ticker[pos - BLOCK_RADIUS, BLOCK_SIZE] = new_bits
  pos += delta_pos
}

puts ticker.sum
