def parse_input(input)
  states = {}

  until input.empty?
    raise 'discarded non-empty line' unless input.shift.strip.empty?

    parsing_state = parse_state(input.shift)
    states[parsing_state] = 2.times.map { |i|
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
  line.chomp[-2].to_sym
end

input = ARGF.readlines

state = parse_state(input.shift)
check_after = Integer(input.shift[/\d+/])
STATES = parse_input(input)

ticker = Hash.new(0)
pos = 0

check_after.times {
  ticker[pos], where_to_go, state = STATES[state][ticker[pos]]
  pos += where_to_go
}

puts ticker.values.sum
