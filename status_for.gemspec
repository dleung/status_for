$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "status_for/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "status_for"
  s.version     = ActsAsStatusFor::VERSION
  s.authors     = ["David Leung"]
  s.email       = ["davleun@gmail.com"]
  s.homepage    = ""
  s.summary     = "Allows tailored status like 'read' or 'deleted' for a class, like a user or message."
  s.description = "Include this in the module which will allow you to search for status for a class."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~>2.0"
  
end
