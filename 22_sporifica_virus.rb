def grid(s, pad_size, clean, infected)
  raise "Size #{s.size}, but must be odd" if s.size.even?

  size = (s.size + 1) / 2
  grid = Array.new(size + pad_size * 2) { Array.new(size + pad_size * 2, clean) }
  c = {?# => infected, ?. => clean}

  # We start pointing up, and thus must start on the bottom of a 2x2 square.
  if (s.size / 2).even?
    # If we would instead start on the top, shift entire grid down.
    s = [?. * s[0].size] + s
  else
    s = s + [?. * s[0].size]
  end

  s.each_slice(2).with_index { |rows, y|
    size = (rows[0].size + 1) / 2
    grid[pad_size + y][pad_size, size] = (0...size).map { |x|
      rows.flat_map { |row| [row[2 * x], row[2 * x + 1] || ?.] }.map(&c).reduce(0) { |acc, ch|
        acc << 2 | ch
      }
    }
  }

  grid
end

# cache key = four squares, position inside, direction
# 0 = up, 1 = right, 2 = down, 3 = left
# cache key => [steps to advance, infects, infect_times, four squares, bottom bits of next cache key]
def make_cache(states)
  # Using Hash[Symbol => Symbol] slows by about 20%,
  # so we translate to integers.
  infected = states.index(:infected)
  clean = states.index(:clean)
  flagged = states.index(:flagged)

  next_state = (0...states.size).to_a.rotate(1).freeze

  dir = {
    [-1, 0] => 0,
    [0, 1] => 1,
    [1, 0] => 2,
    [0, -1] => 3,
  }.freeze

  cache  = Array.new(2 ** 14)

  (0...states.size).to_a.repeated_permutation(4) { |neighbourhood|
    key_prefix = neighbourhood.reduce(0) { |acc, c| acc << 2 | c } << 4
    [
      [-1, 0, 1, 0],
      [-1, 0, 1, 1],
      [1, 0, 0, 0],
      [1, 0, 0, 1],
      [0, -1, 0, 1],
      [0, -1, 1, 1],
      [0, 1, 0, 0],
      [0, 1, 1, 0],
    ].each { |(dy, dx, y, x)|
      key = key_prefix | y << 3 | x << 2 | dir[[dy, dx]]
      raise "conflict on #{key}" if cache[key]

      g = neighbourhood.each_slice(2).to_a
      cn = 0
      infect_times = []
      while (0..1).cover?(x) && (0..1).cover?(y)
        old_status = g[y][x]
        new_status = next_state[old_status]
        infect_times << cn if new_status == infected
        cn += 1
        case old_status
        when clean
          dy, dx = [-dx, dy]
        when infected
          dy, dx = [dx, -dy]
        when flagged
          dy *= -1
          dx *= -1
        end
        g[y][x] = new_status
        y += dy
        x += dx
      end
      cache[key] = [
        cn,
        infect_times.size,
        infect_times.freeze,
        g.flatten.reduce(0) { |acc, c| acc << 2 | c },
        (y % 2) << 3 | (x % 2) << 2 | dir[[dy, dx]],
      ].freeze
    }
  }

  cache.freeze
end

def infects(s, n, states)
  sub_x = (s.size / 2) & 1
  cache = make_cache(states)

  # No I'm not actually sure this padding size is provably correct
  # But instead doing a Hash[Coordinate => State] slows us by 5x-6x.
  # for 10**4, pads by 200. for 10**7, pads by 350.
  # Padding needed for the example is 188 (part 1) and 206 (part 2)
  # and for my input 26 (part 1) and 231 (part 2).
  # (and because of a 2x2 grid, padding needed is halved)
  pad = Math.log(n, 10).ceil * 25
  g = grid(s, pad, states.index(:clean), states.index(:infected))
  width = g[0].size

  # If (s.size / 2) was even, grid got shifted down.
  # If odd, it did not get shifted down; must subtract 1.
  y = x = g.size / 2 - sub_x
  pos = y * width + x
  infects = 0

  g.flatten!

  # lower (sub_y = 1) always, by construction
  # left (sub_x = 0) if x even, right (sub_x = 1) if x odd
  # direction: up (0)
  cache_key = 1 << 3 | sub_x << 2 | 0

  dpos = [-width, 1, width, -1].freeze

  loop {
    cache_key = g[pos] << 4 | cache_key & 0xf
    steps, infects_to_add, infect_times, g[pos], cache_key = cache[cache_key]

    n -= steps
    if n < 0
      n += steps
      return infects + infect_times.count { |it| it < n }
    end

    infects += infects_to_add
    pos += dpos[cache_key & 3]
  }
end

input = ARGF.map { |l| l.chomp.freeze }.freeze

puts infects(input, 10 ** 4, %i(clean infected))
puts infects(input, 10 ** 7, %i(clean weakened infected flagged))
