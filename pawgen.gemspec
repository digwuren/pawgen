Gem::Specification.new do |s|
  s.name = 'pawgen'
  s.version = '1.0.0'
  s.date = '2014-10-20'
  s.homepage = 'https://github.com/digwuren/pawgen'
  s.summary = 'A password generator'
  s.author = 'Andres Soolo'
  s.email = 'dig@mirky.net'
  s.files = File.read('Manifest.txt').split(/\n/)
  s.executables << 'pawgen'
  s.license = 'GPL-2'
  s.description = <<EOD
Pawgen is a password generation tool inspired by Theodore Ts'o's
pwgen.  Generates anglophonemic, kanaphonemic, or syntaxless
passwords.  Implemented in pure Ruby.
EOD
  s.has_rdoc = false
end
