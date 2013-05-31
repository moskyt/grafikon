Gem::Specification.new do |s|
  s.name        = "grafikon"
  s.version     = '0.3.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Frantisek Havluj"]
  s.email       = ["haf@ujv.cz"]
  s.homepage    = "http://orf.ujv.cz"
  s.summary     = "Grafikon"
  s.description = "Simple plotting tool producing Pgfplots source"
  
  s.add_dependency('guttapercha', '~>0.1.7')

  s.files        = Dir.glob("{lib}/**/*") # + %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  s.require_path = 'lib'
end
