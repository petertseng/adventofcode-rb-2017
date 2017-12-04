passwords = ARGF.each_line.map(&:split)

[passwords, passwords.map { |ws| ws.map { |w| w.chars.sort } }].each { |list|
  puts list.count { |x| x.uniq == x }
}
