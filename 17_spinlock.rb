NAIVE = ARGV.delete('--naive')

step_size = Integer(!ARGV.empty? && ARGV.first.match?(/^\d+$/) ? ARGV.first : ARGF.read)

buffer = [0]
pos = 0

(1..2017).each { |n|
  pos = (pos + step_size) % buffer.size
  buffer.insert(pos + 1, n)
  pos += 1
}
puts buffer[pos + 1]

value_after_zero = nil
pos = 0
LIMIT = 50_000_000

if NAIVE
  (1..LIMIT).each { |n|
    pos = (pos + step_size) % n
    value_after_zero = n if pos == 0
    pos += 1
  }
  puts value_after_zero
  exit 0
end

# Instead, do multiple iterations in one go,
# so that we do fewer modulo operations.
n = 0
while n < LIMIT
  value_after_zero = n if pos == 1
  # How many steps fit between `pos` and the next n to wrap?
  # Call this `fits`.
  # Each time we add step_size + 1 steps, so:
  # pos + step_size * fits + fits >= n + fits
  # pos + step_size * fits >= n
  fits = (n - pos) / step_size
  # We advance `fits` times (right before we wrap) and one more (wrap).
  # As noted above, we add (step_size + 1) each time,
  # but we only add the very last step after wrapping + writing.
  n += fits + 1
  pos = (pos + (fits + 1) * (step_size + 1) - 1) % n + 1
end
puts value_after_zero
