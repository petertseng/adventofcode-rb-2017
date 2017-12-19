module ComplexIndex refine Array do
  def [](z)
    super(z.imag)&.[](z.real)
  end
end end

maze = ARGF.map { |l| l.chomp.freeze }.freeze

pos = Complex(maze.first.index(?|), 0)
dir = Complex::I

using ComplexIndex

puts 0.step.with_object('') { |n, letters|
  case (c = maze[pos])
  when ?+
    expected_edge = dir.imag == 0 ? ?| : ?-
    dir = [-1, 1].map { |s| dir * s * Complex::I }.find { |newdir|
      nc = maze[pos + newdir]
      nc == expected_edge || (?A..?Z).cover?(nc)
    }
  when ?A..?Z
    letters << c
  when ' '
    break [letters, n]
  end
  pos += dir
}
