require_relative 'lib/knot_hash'

part_2_only = ARGV.delete('-2')

input = (!ARGV.empty? && ARGV.first.include?(?,) ? ARGV.first : ARGF.read).chomp.freeze

puts KnotHash::twist(input.split(?,).map(&method(:Integer)), 1).take(2).reduce(:*) unless part_2_only

puts KnotHash::hash(input.bytes + KnotHash::SUFFIX)
