# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "rack-passbook"
  s.authors     = ["Mattt Thompson"]
  s.email       = "m@mattt.me"
  s.homepage    = "http://mattt.me"
  s.version     = '0.2.0'
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Rack::Passbook"
  s.description = "Automatically generate REST APIs for Passbook registration."

  s.add_development_dependency "rspec", "~> 0.6"
  s.add_development_dependency "rake",  "~> 0.9"

  s.add_dependency "rack", "~> 1.4"
  s.add_dependency "sinatra", "~> 1.3"
  s.add_dependency "sequel", "~> 3.37"

  s.files         = Dir["./**/*"].reject { |file| file =~ /\.\/(bin|example|log|pkg|script|spec|test|vendor)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
