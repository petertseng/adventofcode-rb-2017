require 'set'

def jump_offset(inst)
  inst[0].to_s[0] == ?j ? inst[-1] : nil
end

def always_jumps?(inst)
  case inst[0]
  when :jnz
    inst[1].is_a?(Integer) && inst[1] != 0
  when :jmp
    true
  else raise "Unknown #{inst}"
  end
end

def never_jumps?(inst)
  case inst[0]
  when :jnz
    inst[1].is_a?(Integer) && inst[1] == 0
  when :jmp
    false
  else raise "Unknown #{inst}"
  end
end

def jump_cond(inst)
  case inst[0]
  when :jnz
    [inst[1], :!=, 0]
  else raise "Unknown #{inst}"
  end
end

def reads(inst)
  regs = case inst[0]
  when :if
    [inst[1][0], inst[1][-1]]
  when :sub
    # Since this is a -=, it's considered a read and a write.
    [inst[1], inst[-1]]
  when :mul
    # Since this is a *=, it's considered a read and a write.
    [inst[1], inst[-1]]
  when :set
    [inst[-1]]
  when :jmp
    []
  else raise "Unknown #{inst}"
  end
  regs.select { |r| r.is_a?(Symbol) }
end

def writes(inst)
  case inst[0]
  when :if
    []
  when :sub
    [inst[1]]
  when :mul
    [inst[1]]
  when :set
    [inst[1]]
  when :jmp
    []
  else raise "Unknown #{inst}"
  end
end

LABELS_ALLOCATED = [0]
def new_label
  "L#{LABELS_ALLOCATED[0] += 1}"
end

insts = ARGF.map { |l|
  inst, *args = l.split
  {
    inst: [inst.to_sym, *args.map { |a| a.match?(/-?\d+/) ? a.to_i : a.to_sym }],
    label: nil,
    note: nil,
  }
}.freeze

# Make all jumps absolute
insts.each_with_index { |inst, i|
  next unless (offset = jump_offset(inst[:inst]))

  if always_jumps?(inst[:inst])
    inst[:inst][0..1] = [:jmp]
  elsif never_jumps?(inst[:inst])
    inst[:inst] = [:nop]
    next
  end

  unless offset.is_a?(Integer)
    inst[:note] = 'Argh, variable jump!'
    next
  end

  jump_to = i + offset
  if jump_to < 0 || !(jump_to = insts[jump_to])
    inst[:inst][-1] = :exit
    next
  end

  jump_to[:label] ||= new_label
  inst[:inst][-1] = jump_to[:label]
}

# Decide where each conditional jump will go to in both cases.
insts.each_cons(2) { |i0, i1|
  next unless jump_offset(i0[:inst])
  next if always_jumps?(i0[:inst])
  after_always_jumps = jump_offset(i1[:inst]) && always_jumps?(i1[:inst])

  cond = jump_cond(i0[:inst])
  # If instruction after isn't a jump, then make a label for it.
  # This will make it the start of a basic block.
  false_dest = after_always_jumps ? i1[:inst][-1] : (i1[:label] ||= new_label)
  i0[:inst] = [:if, cond, i0[:inst][-1], false_dest]
  # So now we have
  # if (cond) L1 else L2

  # Convert all sequence of:
  # conditional jump to L1
  # unconditional jump to L2
  # to:
  # if (cond) L1 else L2
  # nop (to be cleaned up later)
  if after_always_jumps
    if i1[:label]
      dest = i1[:inst][-1]
      insts.each { |inst|
        # Anyone who was jumping to my label, just jump to my dest.
        inst[:inst][-1] = dest if jump_offset(inst[:inst]) && inst[:inst][-1] == i1[:label]
      }
    end
    i1[:inst] = [:nop]
  end
}

basic_blocks = insts.reject { |i|
  # delete nops that may have resulted from previous step.
  raise "Don't forget to change the label" if i[:inst] == [:nop] && i[:label]
  i[:inst] == [:nop]
}.slice_before { |i| i[:label] }.map.with_index { |is, i|
  # At this point I don't need the :label on each inst,
  # since only first instruction in each BB has one.
  # Might as well get rid of them all to avoid confusion.
  labels = is.map { |inst| inst.delete(:label) }
  {id: i, preds: [], insts: is, label: labels[0]}
}

by_label = basic_blocks.to_h { |bb| [bb[:label], bb] }

basic_blocks.each { |bb|
  last_inst = bb[:insts][-1][:inst]
  if last_inst[0] == :if
    # Conditional jump
    last_inst.values_at(-2, -1).each { |label|
      next if label == :exit
      by_label[label][:preds] << bb[:id]
    }
  elsif jump_offset(last_inst)
    # Expect this to be an unconditional jump
    raise "Unexpected #{last_inst}; all conditional jumps should be IF by now" unless always_jumps?(last_inst)
    next if last_inst[-1] == :exit
    by_label[last_inst[-1]][:preds] << bb[:id]
  else
    # Not a jump, falling through.
    fallthrough = basic_blocks[bb[:id] + 1]
    fallthrough[:preds] << bb[:id] if fallthrough
  end
}

all_regs = Set.new
all_read_before_written = Set.new

# Identify any temporary variables,
# so that we may try to optimise them out.
basic_blocks.each_with_index { |bb, i|
  regs = Set.new
  read_before_written = Set.new

  bb[:insts].reverse_each { |inst|
    reads = reads(inst[:inst])
    writes = writes(inst[:inst])
    regs += writes
    regs += reads
    # Remove writes before adding reads, since there are op= instructions.
    # a += 2 will first read a then write it,
    # so register a should go in read_before_written on an op= instruction.
    read_before_written -= writes
    read_before_written += reads
  }

  all_regs += regs
  all_read_before_written += read_before_written
}

# temporary variables are never read before they're written.
tempvars = all_regs - all_read_before_written
puts "Tempvars: #{tempvars.to_a}"
puts

# Try to eliminate some obvious uses of temporaries.
tempvars.each { |tmp|
  basic_blocks.each { |bb|
    i = -1
    squash_instructions = ->(n) {
      bb[:insts][i][:inst] = bb[:insts][i + n - 1][:inst]
      bb[:insts][i][:note] = (0...n).flat_map { |j| bb[:insts][i + j][:note] }.compact
      (n - 1).times {
        bb[:insts].delete_at(i + 1)
      }
    }
    inst = ->(j) { bb[:insts][j][:inst] }

    # Not doing each because bb[:insts].size might change.

    i = -1
    while (i += 1) + 2 < bb[:insts].size
      # set tmp a
      # sub tmp b
      # if [tmp != 0] x y
      # ->
      # if [a != b] x y
      next unless inst[i][0..1] == [:set, tmp]
      next unless inst[i + 1][0..1] == [:sub, tmp]
      next unless inst[i + 2][0..1] == [:if, [tmp, :!=, 0]]
      inst[i + 2][1][0] = inst[i][2]
      inst[i + 2][1][2] = inst[i + 1][2]
      squash_instructions[3]
    end

    i = -1
    while (i += 1) + 3 < bb[:insts].size
      # set tmp a
      # mul tmp b
      # sub tmp c
      # if [tmp != 0] x y
      # ->
      # if [a * b != c] x y
      next unless inst[i][0..1] == [:set, tmp]
      next unless inst[i + 1][0..1] == [:mul, tmp]
      next unless inst[i + 2][0..1] == [:sub, tmp]
      next unless inst[i + 3][0..1] == [:if, [tmp, :!=, 0]]
      inst[i + 3][1][0] = inst[i][2]
      inst[i + 3][1].insert(1, :*)
      inst[i + 3][1].insert(2, inst[i + 1][2])
      inst[i + 3][1][-1] = inst[i + 2][2]
      squash_instructions[4]
    end

    i = -1
    while (i += 1) + 2 < bb[:insts].size
      # set tmp 0
      # sub tmp a
      # sub b tmp
      # ->
      # add b a
      next unless inst[i] == [:set, tmp, 0]
      next unless inst[i + 1][0..1] == [:sub, tmp]
      next unless inst[i + 2][0] == :sub
      next unless inst[i + 2][2] == tmp
      inst[i + 2][0] = :add
      inst[i + 2][2] = inst[i + 1][2]
      squash_instructions[3]
    end
  }
}

# We've done all we can, the rest is up to the human.
basic_blocks.each_with_index { |bb, i|
  loop_start = bb[:preds].any? { |p| p >= i }
  puts "# blk#{i}, preds: #{bb[:preds]}#{" (loop start)" if loop_start}"
  bb[:insts].each { |inst|
    puts inst[:inst].map { |arg|
      # Map labels to block numbers
      arg.is_a?(String) && arg[0] == ?L ? "blk#{by_label[arg][:id]}" : arg
    }.join(' ') + (inst[:note] && !inst[:note].empty? ? "# #{inst[:note]}" : '')
  }
  puts
}
