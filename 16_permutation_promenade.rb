def dance(orig, steps)
  steps.each_with_object(orig.dup) { |step, progs|
    args = step[1..-1]
    case step[0]
    when ?s
      progs.replace(progs.chars.rotate(-args.to_i).join)
    when ?x
      l, r = args.scan(/\d+/).map(&:to_i)
      progs[l], progs[r] = [progs[r], progs[l]]
    when ?p
      l, r = args.split(?/)
      progs.tr!(l + r, r + l)
    else raise "Unknown dance step #{step}"
    end
  }
end

input = ARGF.read.split(?,).map(&:freeze).freeze

progs = [(?a..?p).to_a.join.freeze]

loop {
  progs << dance(progs[-1], input).freeze
  break if progs[-1] == progs[0]
}

progs.pop

puts progs[1]
puts progs[1_000_000_000 % progs.length]
