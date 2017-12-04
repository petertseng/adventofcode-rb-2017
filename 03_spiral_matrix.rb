input = Integer(!ARGV.empty? && ARGV.first.match?(/^\d+$/) ? ARGV.first : ARGF.read)

ORIGIN = Complex(0, 0)

def spiral_matrix(corners_only: false)
  pos = ORIGIN
  direction = 1
  length = 1
  n = 1

  Enumerator.new { |e|
    e << [1, pos]
    loop {
      if corners_only
        n += length
        pos += direction * length
        e << [n, pos]
      else
        length.times { |i|
          n += 1
          pos += direction
          e << [n, pos]
        }
      end
      direction *= Complex::I
      length += 1 if direction.imag == 0
    }
  }
end

# The corners of the side of the square that contain the input,
# and the input's distance to each:
dists_and_corners = spiral_matrix(corners_only: true).each_cons(2).find { |(_, _), (n, _)|
  n >= input
}.map { |n, d| [(input - n).abs, d] }
# The closer corner:
dist, corner = dists_and_corners.min_by(&:first)
# One coordinate the same as the corner, the other decreased by the distance.
puts corner.real.abs + corner.imag.abs - dist

values = {ORIGIN => 1}
puts spiral_matrix.lazy.map { |_, pos|
  values[pos] = [-1, 0, 1].sum { |dy|
    [-1, 0, 1].sum { |dx|
      values[pos + dx + Complex::I * dy] || 0
    }
  }
}.find { |n| n > input }
