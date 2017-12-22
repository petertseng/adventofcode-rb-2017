def grid(s, pad_size, clean, infected)
  grid = Array.new(s.size + pad_size * 2) { Array.new(s.size + pad_size * 2, clean) }
  c = {?# => infected, ?. => clean}
  s.each_with_index { |row, y|
    grid[pad_size + y][pad_size, row.size] = row.each_char.map(&c)
  }
  grid
end

def infects(s, n, states)
  # Using Hash[Symbol => Symbol] slows by about 20%,
  # so we translate to integers.
  infected = states.index(:infected)
  clean = states.index(:clean)
  flagged = states.index(:flagged)

  # No I'm not actually sure this padding size is provably correct
  # But instead doing a Hash[Coordinate => State] slows us by 5x-6x.
  # for 10**4, pads by 200. for 10**7, pads by 350.
  # Padding needed for the example is 188 (part 1) and 206 (part 2)
  # and for my input 26 (part 1) and 231 (part 2).
  pad = Math.log(n, 10).ceil * 50
  g = grid(s, pad, clean, infected)
  y = x = g.size / 2
  dy = -1
  dx = 0
  infects = 0

  next_state = (0...states.size).to_a.rotate(1).freeze

  n.times {
    old_status = g[y][x]
    new_status = next_state[old_status]
    infects += 1 if new_status == infected
    # Strangely, case/when slows by about 30%?!
    # Maybe Integer#=== is expensive?
    if old_status == clean
      dy, dx = [-dx, dy]
    elsif old_status == infected
      dy, dx = [dx, -dy]
    elsif old_status == flagged
      dy *= -1
      dx *= -1
    end
    g[y][x] = new_status
    y += dy
    x += dx
  }

  infects
end

input = ARGF.map { |l| l.chomp.freeze }.freeze

puts infects(input, 10 ** 4, %i(clean infected))
puts infects(input, 10 ** 7, %i(clean weakened infected flagged))
