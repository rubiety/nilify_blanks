# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nilify_blanks/version"

Gem::Specification.new do |s|
  s.name        = "nilify_blanks"
  s.version     = NilifyBlanks::VERSION
  s.license     = 'MIT'
  s.author      = "Ben Hughes"
  s.email       = "ben@railsgarden.com"
  s.homepage    = "https://github.com/rubiety/nilify_blanks"
  s.summary     = "Auto-convert blank fields to nil."
  s.description = "Often times you'll end up with empty strings where you really want nil at the database level.  This plugin automatically converts blanks to nil and is configurable."

  s.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"]
  s.require_path = "lib"

  s.required_rubygems_version = ">= 1.3.4"

  s.add_dependency("activesupport", [">= 4.0.0"])
  s.add_dependency("activerecord", [">= 4.0.0"])
  s.add_development_dependency("rake", "~> 13.0.1")
  s.add_development_dependency("rspec", [">= 3.8.0"])
  s.add_development_dependency("appraisal", [">= 1.0.2"])
end
