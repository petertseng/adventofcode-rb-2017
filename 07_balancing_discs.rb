def the_single(thing, l)
  raise "Not one #{thing}? #{l}" if l.size != 1
  l.first
end

children = {}
own_weights = {}

ARGF.each_line { |l|
  name = l.split[0]
  weight = Integer(l[/\d+/])
  my_children = l.include?('->') ? l.split('->')[1].split(?,).map(&:strip) : []
  own_weights[name] = weight
  children[name] = my_children.freeze
}

children.freeze
own_weights.freeze

bottom = the_single('bottom', own_weights.keys - children.values.flatten)
puts bottom

total_weights = {}
total = ->(n) {
  total_weights[n] ||= own_weights[n] + children[n].sum(&total)
}
_ = total[bottom]
total_weights.freeze

at = bottom
prev_weight = nil
until (weights = children[at].group_by(&total_weights)).size == 1
  singles = weights.select { |_, w| w.size == 1 }
  at = the_single('single', singles.values)[0]
  prev_weight = the_single('previous weight', weights.keys - singles.keys)
end

puts own_weights[at] - (total[at] - prev_weight)
