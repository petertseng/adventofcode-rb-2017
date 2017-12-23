require 'prime'

def run(insts, debug: true)
  regs = Hash.new(0)
  regs[:a] = debug ? 0 : 1
  pc = -1
  muls = 0
  resolve = ->(y) { y.is_a?(Integer) ? y : regs[y] }

  while (pc += 1) >= 0 && (inst = insts[pc])
    if !debug && pc == 8
      regs[:f] = Prime.prime?(regs[:b]) ? 1 : 0
      pc += 15
      next
    end

    case inst[0]
    when :sub
      regs[inst[1]] -= resolve[inst[2]]
    when :set
      regs[inst[1]] = resolve[inst[2]]
    when :mul
      muls += 1
      regs[inst[1]] *= resolve[inst[2]]
    when :jnz
      pc += (resolve[inst[2]] - 1) if resolve[inst[1]] != 0
    else raise "Unknown instruction #{inst}"
    end
  end

  debug ? muls : regs[:h]
end

insts = ARGF.map { |l|
  inst, *args = l.split
  [inst.to_sym, *args.map { |a| a.match?(/-?\d+/) ? a.to_i : a.to_sym }].freeze
}.freeze

[true, false].each { |debug| puts run(insts, debug: debug) }
