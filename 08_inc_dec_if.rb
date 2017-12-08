input = ARGF.each_line.map(&:split)

regs = Hash.new(0)
max = 0

input.each { |target, inc_or_dec, delta, _if, cmp_reg, cmp_op, cmp_val|
  next unless regs[cmp_reg].send(cmp_op, Integer(cmp_val))
  new_val = regs[target] += Integer(delta) * (inc_or_dec == 'dec' ? -1 : 1)
  max = [max, new_val].max
}

puts regs.values.max
puts max
