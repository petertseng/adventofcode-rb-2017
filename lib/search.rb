require 'set'

module Search
  module_function

  def bfs(start, neighbours, goal)
    queue = [start]
    seen = Set.new

    while (n = queue.pop)
      next if seen.include?(n)
      return [true, n] if goal[n]
      seen << n
      queue.concat(neighbours[n])
    end

    [false, seen.freeze]
  end
end
