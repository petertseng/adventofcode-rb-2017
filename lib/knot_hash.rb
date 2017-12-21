module KnotHash
  SUFFIX = [17, 31, 73, 47, 23].freeze

  module_function

  c_lib = File.join(__dir__, '..', 'c', 'libknothash.so').freeze
  if File.exist?(c_lib)
    require 'fiddle'

    lib = Fiddle.dlopen(c_lib)
    TWIST = Fiddle::Function.new(
      lib['twist'],
      [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_SIZE_T],
      Fiddle::TYPE_VOID,
    )

    def twist(lengths, n)
      buf = (0...256).to_a.pack('C*')
      TWIST.call(
        Fiddle::Pointer[buf],
        Fiddle::Pointer[lengths.pack('C*')],
        lengths.size,
        n,
      )
      buf.unpack('C*')
    end
  else
    def twist(lengths, n)
      pos = 0
      skip_size = 0
      deferred_rotate = 0

      n.times.with_object((0..255).to_a) { |_, l|
        lengths.each { |len|
          l.rotate!(pos + deferred_rotate)
          l[0, len] = l[0, len].reverse
          # We would rotate by -pos here,
          # but defer it until the next so we do fewer rotates.
          deferred_rotate = -pos
          pos += len + skip_size
          skip_size += 1
        }
      }.rotate!(deferred_rotate)
    end
  end

  def hash(lengths)
    twist(lengths, 64).each_slice(16).map { |byte|
      byte.reduce(0, :^).to_s(16).rjust(2, ?0)
    }.join
  end
end
