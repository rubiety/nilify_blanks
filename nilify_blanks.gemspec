# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nilify_blanks/version"

Gem::Specification.new do |s|
  s.name        = "nilify_blanks"
  s.version     = NilifyBlanks::VERSION
  s.author      = "Ben Hughes"
  s.email       = "ben@railsgarden.com"
  s.homepage    = "http://github.com/rubiety/nilify_blanks"
  s.summary     = "Auto-convert blank fields to nil."
  s.description = "Often times you'll end up with empty strings where you really want nil at the database level.  This plugin automatically converts blanks to nil and is configurable."
  
  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"]
  s.require_path = "lib"
  
  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
  
  s.add_dependency("activesupport", [">= 3.0.0"])
  s.add_dependency("activerecord", [">= 3.0.0"])
  s.add_development_dependency("rake", ["~> 10.0.3"])
  s.add_development_dependency("rspec", ["~> 2.13"])
  s.add_development_dependency("sqlite3", ["~> 1.3.6"])
end
