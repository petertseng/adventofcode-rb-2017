passwords = ARGF.map { |l| l.split.map(&:freeze).freeze }.freeze

[passwords, passwords.map { |ws| ws.map { |w| w.chars.sort } }].each { |list|
  puts list.count { |x| x.uniq == x }
}
