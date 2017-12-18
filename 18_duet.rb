def run(insts, id, tx, rx)
  regs = Hash.new(0)
  regs[:p] = id
  vals_received = 0
  pc = 0
  resolve = ->(y) { y.is_a?(Integer) ? y : regs[y] }

  -> {
    ran_anything = false

    while pc >= 0 && (inst = insts[pc])
      case inst[0]
      when :snd
        tx << resolve[inst[1]]
      when :set
        regs[inst[1]] = resolve[inst[2]]
      when :add
        regs[inst[1]] += resolve[inst[2]]
      when :mul
        regs[inst[1]] *= resolve[inst[2]]
      when :mod
        regs[inst[1]] %= resolve[inst[2]]
      when :rcv
        if tx.object_id == rx.object_id
          # Part 1!
          return rx[-1] if resolve[inst[1]] != 0
        else
          # Part 2!
          return ran_anything ? :wait : :still_waiting unless (val = rx[vals_received])
          vals_received += 1
          regs[inst[1]] = val
        end
      when :jgz
        pc += (resolve[inst[2]] - 1) if resolve[inst[1]] > 0
      else raise "Unknown instruction #{inst}"
      end

      pc += 1
      ran_anything = true
    end

    :finished
  }
end

insts = ARGF.map { |l|
  inst, *args = l.split
  [inst.to_sym, *args.map { |a| a.match?(/-?\d+/) ? a.to_i : a.to_sym }].freeze
}.freeze

sound = []
puts run(insts, 0, sound, sound)[]

send = [[], []]
runners = [0, 1].map { |id| run(insts, id, send[id], send[1 - id]) }
other_was_waiting = false
puts 0.step { |n|
  status = runners[n % 2][]
  if status == :still_waiting && other_was_waiting
    # Deadlocked.
    break send[1].size
  end
  other_was_waiting = status == :still_waiting
}
