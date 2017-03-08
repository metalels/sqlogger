$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sqlogger/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sqlogger"
  s.version     = Sqlogger::VERSION
  s.authors     = ["metalels"]
  s.email       = ["metalels86@gmail.com"]
  s.homepage    = "https://github.com/metalels/sqlogger"
  s.summary     = "Collect 'ActiveRecord sql query' to monitoring system(s)."
  s.description = "Collect 'ActiveRecord sql query' to monitoring system(s)."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 3.1.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"
  s.add_development_dependency "webmock"
end
