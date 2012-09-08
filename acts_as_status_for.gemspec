$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_status_for/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_status_for"
  s.version     = ActsAsStatusFor::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ActsAsStatusFor."
  s.description = "TODO: Description of ActsAsStatusFor."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~>2.0"
  
end