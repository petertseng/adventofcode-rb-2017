require 'base64'

base = Base64.decode64('Pz0pQUI7Ch cmER8YDAEYAh4L GwEP').bytes.freeze

def xor(base, key)
  base.zip(key.cycle).map { |a, b| a ^ b }
end

def possible(base, len, *is)
  (0..255).select { |x|
    xored = xor(base, Array.new(len) { |n| is.include?(n) ? x : 0 })
    bytes_in_question = xored.each_slice(len).flat_map { |c| c.values_at(*is) }.compact
    # If it's base64...
    # 45 and 95 for - and _? (url-safe alphabet)
    bytes_in_question.all? { |b| (65..90).cover?(b) || (97..122).cover?(b) || b == 43 || b == 47 || b == 61 || b == 45 || b == 95 }
    # Just printables
    #bytes_in_question.all? { |b| b == 10 || (32..126).cover?(b) }
  }
end

if false
  base64 = (?A..?Z).to_a + (?a..?z).to_a + (?0..?9).to_a + [?+, ?/]
  a = 'Pz0pQUI7ChcmER8YDAEYAh4LGwEP'.each_char.map { |x| base64.index(x) }
  b = Base64.encode64('↑↑↓↓←→←→BA').strip
  b = b.delete(?=).each_char.map { |x| base64.index(x) }
  puts Base64.decode64(xor(a, b).map { |c| base64[c] }.join)
end

#puts xor(base, '88224646BA'.bytes).pack('c*')
#puts xor(base, 0x88224646ba.digits(256)).pack('c*')
#puts xor(base, '^^vv<><>BA'.bytes).pack('c*')
#puts xor(base, '^^VV<><>BA'.bytes).pack('c*')
#puts xor(base, 'UUDDLRLRBA'.bytes).pack('c*')
#puts xor(base, 'uuddlrlrba'.bytes).pack('c*')
#puts xor(base, 'upupdowndownleftrightleftrightBA'.bytes).pack('c*')
#puts xor(base, 'UPUPDOWNDOWNLEFTRIGHTLEFTRIGHTBA'.bytes).pack('c*')
#puts xor(base, 'konamicode'.bytes).pack('c*')
puts xor(base, 'konami'.bytes).pack('c*').tr("a-zA-Z", "n-za-mN-ZA-M")
exit 0
#puts xor(base, 'KONAMICODE'.bytes).pack('c*')
#puts xor(base, 'nnssweweba'.bytes).pack('c*')
#puts xor(base, 'NNSSWEWEBA'.bytes).pack('c*')

def try10(base)
  possibles = [
    possible(base, 10, 0, 1),
    possible(base, 10, 2, 3),
    possible(base, 10, 4, 6),
    possible(base, 10, 5, 7),
    possible(base, 10, 8),
    possible(base, 10, 9),
  ]

  possibles.each_with_index { |possible, i|
    puts "#{i} #{possible.size}: #{possible}"
  }

  leaderboard = /[0-9]+-[0-9a-f]{8}/
  url = /\.com?\//

  nkeys = possibles.map(&:size).reduce(1, :*)
  puts nkeys

  t = Time.now

  i = 0
  possibles[0].each { |x1|
    possibles[1].each { |x2|
      possibles[2].each { |x3|
        possibles[3].each { |x4|
          possibles[4].each { |x5|
            possibles[5].each { |x6|
              puts "#{Time.now - t} #{i}/#{nkeys}" if i % 1_000_000 == 0

              key = [x1, x2, x3, x4, x5, x6]
              xored = xor(base, key).pack('c*')
              msg = Base64.decode64(xored) rescue nil
              if msg.nil? && (msg.include?(?-) || msg.include?(?_))
                msg = Base64.urlsafe_decode64(xored) rescue nil
              end
              #msg = xor(base, key).pack('c*')
              puts "#{Time.now - t} #{key.pack('c*')} (#{i + 1}/#{nkeys}): #{msg}" if msg.size > 2 && msg.bytes.all? { |c| c == 10 || (32..126).cover?(c) }
              #puts "#{Time.now - t} #{key.pack('c*')} (#{i + 1}/#{nkeys}): #{msg}" if msg.match?(leaderboard) || msg.match?(url)

              i += 1
            }
          }
        }
      }
    }
  }
end

def try6(base)
  possibles = (0...6).map { |i| possible(base, 6, i).select { |x| (?a.ord..?z.ord).cover?(x) } }

  possibles.each_with_index { |possible, i|
    puts "#{i} #{possible.size}: #{possible}"
  }

  leaderboard = /[0-9]+-[0-9a-f]{8}/
  url = /\.com?\//

  nkeys = possibles.map(&:size).reduce(1, :*)
  puts nkeys

  t = Time.now

  i = 0
  possibles[0].each { |x1|
    possibles[1].each { |x2|
      possibles[2].each { |x3|
        possibles[3].each { |x4|
          possibles[4].each { |x5|
            possibles[5].each { |x6|
              puts "#{Time.now - t} #{i}/#{nkeys}" if i % 1_000_000 == 0

              key = [x1, x2, x3, x4, x5, x6]
              xored = xor(base, key).pack('c*')
              msg = Base64.decode64(xored) rescue nil
              if msg.nil? && (msg.include?(?-) || msg.include?(?_))
                msg = Base64.urlsafe_decode64(xored) rescue nil
              end
              #msg = xor(base, key).pack('c*')
              puts "#{Time.now - t} #{key.pack('c*')} (#{i + 1}/#{nkeys}): #{msg}" if msg.size > 2 && msg.bytes.all? { |c| c == 10 || (32..126).cover?(c) }
              #puts "#{Time.now - t} #{key.pack('c*')} (#{i + 1}/#{nkeys}): #{msg}" if msg.match?(leaderboard) || msg.match?(url)

              i += 1
            }
          }
        }
      }
    }
  }
end

def try_crib(base, crib)
  base.each_cons(crib.size) { |base_part|
    p xor(base_part, crib.bytes).pack('c*')
  }
end

['http', '.co', 'www.'].each { |x|
  puts ?= * 40 + x + ?= * 40
  try_crib(base, x)
}
try10(base)
try6(base)
