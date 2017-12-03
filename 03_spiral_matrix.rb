input = Integer(!ARGV.empty? && ARGV.first.match?(/^\d+$/) ? ARGV.first : ARGF.read)

ORIGIN = Complex(0, 0)

def spiral_matrix
  pos = ORIGIN
  direction = 1
  length = 1
  n = 1

  Enumerator.new { |e|
    e << [1, pos]
    loop {
      length.times { |i|
        n += 1
        pos += direction
        e << [n, pos]
      }
      direction *= Complex::I
      length += 1 if direction.imag == 0
    }
  }
end

_, coord = spiral_matrix.take(input).last
puts coord.real.abs + coord.imag.abs

values = {ORIGIN => 1}
puts spiral_matrix.lazy.map { |_, pos|
  values[pos] = [-1, 0, 1].sum { |dy|
    [-1, 0, 1].sum { |dx|
      values[pos + dx + Complex::I * dy] || 0
    }
  }
}.find { |n| n > input }
