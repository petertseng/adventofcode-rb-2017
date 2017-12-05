def run(input)
  input = input.dup
  n = 0
  pc = 0
  while pc >= 0 && (offset = input[pc])
    n += 1
    input[pc] = yield offset
    pc += offset
  end
  n
end

input = ARGF.each_line.map(&method(:Integer))

puts run(input, &:succ)
puts run(input) { |n| n + (n >= 3 ? -1 : 1) }
