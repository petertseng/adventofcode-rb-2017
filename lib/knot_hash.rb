module KnotHash
  SUFFIX = [17, 31, 73, 47, 23].freeze

  module_function

  def twist(lengths, n)
    pos = 0
    skip_size = 0

    n.times.with_object((0..255).to_a) { |_, l|
      lengths.each { |len|
        if pos + len <= 256
          l[pos, len] = l[pos, len].reverse
        else
          right_len = 256 - pos
          left_len = len - right_len
          elts = l[pos, right_len] + l[0, left_len]
          elts.reverse!
          l[pos, right_len] = elts[0, right_len]
          l[0, left_len] = elts[right_len, left_len]
        end
        pos += len + skip_size
        pos %= 256
        skip_size += 1
      }
    }
  end

  def hash(lengths)
    twist(lengths, 64).each_slice(16).map { |byte|
      byte.reduce(0, :^).to_s(16).rjust(2, ?0)
    }.join
  end
end
