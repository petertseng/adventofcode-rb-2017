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

c_lib = File.join(__dir__, 'c', 'lib05.so')
if File.exist?(c_lib)
  require 'fiddle'

  lib = Fiddle.dlopen(c_lib)
  ['part1', 'part2'].map { |f| Fiddle::Function.new(
    lib[f], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T], Fiddle::TYPE_SIZE_T,
  )}.each { |f| puts f.call(Fiddle::Pointer[input.pack('i*')], input.size) }

  exit 0
end

puts run(input, &:succ)
puts run(input) { |n| n + (n >= 3 ? -1 : 1) }
