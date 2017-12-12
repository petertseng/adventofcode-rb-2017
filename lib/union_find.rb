class UnionFind
  attr_reader :num_sets

  def initialize(things, storage: Hash)
    @orig_things = things.freeze
    @num_sets = things.size
    if storage == Hash
      @parent = things.map { |x| [x, x] }.to_h
      @size = things.to_h { |x| [x, 1] }
      @rank = things.map { |x| [x, 0] }.to_h
    elsif storage == Array
      m = things.max
      @parent = Array.new(m + 1, &:itself)
      @size = Array.new(m + 1, 1)
      @rank = Array.new(m + 1, 0)
    else raise "invalid storage #{storage}"
    end
  end

  def size(x)
    @size[find(x)]
  end

  def union(x, y)
    xp = find(x)
    yp = find(y)

    return if xp == yp

    if @rank[xp] < @rank[yp]
      @parent[xp] = yp
    elsif @rank[xp] > @rank[yp]
      @parent[yp] = xp
    else
      @parent[yp] = xp
      @rank[xp] += 1
    end
    @num_sets -= 1
  end

  # Just checking whether one's more expensive than the other
  def union_sz(x, y)
    xp = find(x)
    yp = find(y)

    return if xp == yp

    if @size[xp] <= @size[yp]
      @parent[xp] = yp
      @size[yp] += @size[xp]
    elsif @size[xp] > @size[yp]
      @parent[yp] = xp
      @size[xp] += @size[yp]
    end
    @num_sets -= 1
  end

  def find(x)
    @parent[x] = find(@parent[x]) if @parent[x] != x
    @parent[x]
  end

  def sets
    @orig_things.group_by(&method(:find)).values.map(&:freeze).freeze
  end
end
