input = ARGF.read.chomp

# Remove the ! and characters they cancel.
# This only works given that gsub does not find overlapping groups
# (so that !!x turns into x, not empty string)
# and that ! and the char it cancels aren't counted in garbage.
input.gsub!(/!./, '')

score = 0
open_groups = 0
garbage = false
garbages = 0

input.each_char { |x|
  garbages += 1 if garbage && x != ?>

  case x
  when ?{
    open_groups += 1 unless garbage
  when ?}
    unless garbage
      score += open_groups
      open_groups -= 1
    end
  when ?<
    garbage = true
  when ?>
    garbage = false
  end
}

puts score
puts garbages
