require_relative 'lib/knot_hash'

input = (!ARGV.empty? && ARGV.first.include?(?,) ? ARGV.first : ARGF.read).chomp

puts KnotHash::twist(input.split(?,).map(&:to_i), 1).take(2).reduce(:*)

puts KnotHash::hash(input.bytes + KnotHash::SUFFIX)
