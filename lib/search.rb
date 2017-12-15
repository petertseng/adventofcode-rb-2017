require 'set'

module Search
  module_function

  def bfs(start, neighbours, goal)
    queue = [[start, 0]]
    seen = Set.new

    while (n, gen = queue.pop)
      next if seen.include?(n)
      return [true, gen, n] if goal[n]
      seen << n
      queue.concat(neighbours[n].map { |x| [x, gen + 1] })
    end

    [false, gen, seen.freeze]
  end
end
