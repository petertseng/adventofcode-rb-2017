def run(input, lim)
  input = input.dup
  n = 0
  pc = 0
  while pc >= 0 && (offset = input[pc])
    n += 1
    input[pc] = offset + (offset >= lim ? -1 : 1)
    pc += offset
  end
  n
end

input = ARGF.map(&method(:Integer)).freeze

puts run(input, Float::INFINITY)
puts run(input, 3)
