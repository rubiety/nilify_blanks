# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{nilify_blanks}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Hughes"]
  s.date = %q{2009-03-09}
  s.description = %q{Auto-convert blank fields to nil.}
  s.email = %q{ben@railsgarden.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/nilify_blanks.rb", "README.rdoc", "tasks/nilify_blanks_tasks.rake"]
  s.files = ["CHANGELOG", "init.rb", "install.rb", "lib/nilify_blanks.rb", "Manifest", "MIT-LICENSE", "nilify_blanks.gemspec", "nilify_blanks_plugin.sqlite3", "Rakefile", "README.rdoc", "tasks/nilify_blanks_tasks.rake", "test/config/database.yml", "test/nilify_blanks_plugin.sqlite3", "test/nilify_blanks_test.rb", "test/schema.rb", "test/test_helper.rb", "uninstall.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/railsgarden/nilify_blanks}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Nilify_blanks", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{nilify_blanks}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Auto-convert blank fields to nil.}
  s.test_files = ["test/nilify_blanks_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
