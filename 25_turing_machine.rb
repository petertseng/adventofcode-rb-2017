def parse_input(input)
  input.each("\n\n", chomp: true).to_h { |state|
    lines = state.lines
    parsing_state = parse_state(lines.shift)
    [parsing_state, 2.times.map { |i|
      # Assume input comes in order.
      parse_rule(i, lines.shift(4))
    }.freeze]
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
  line.chomp[-2].to_sym
end

state = parse_state(ARGF.readline)
check_after = Integer(ARGF.readline[/\d+/])
unless (empty = ARGF.readline).chomp.empty?
  raise "#{empty} should have been empty"
end
STATES = parse_input(ARGF)

ticker = Hash.new(0)
pos = 0

check_after.times {
  ticker[pos], where_to_go, state = STATES[state][ticker[pos]]
  pos += where_to_go
}

puts ticker.values.sum
