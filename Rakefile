require 'bundler/gem_tasks'
require 'appraisal'
require 'rspec/core/rake_task'

require 'bundler/setup'

require 'rake'
require 'rspec/core/rake_task'

desc "Default: run unit tests."
task default: [:clean, :all]

task test: :spec

desc "Test this plugin under all supported Rails versions."
task :all do |t|
  if ENV['BUNDLE_GEMFILE']
    exec('rake spec && cucumber')
  else
    exec("rm -f gemfiles/*.lock")
    Rake::Task["appraisal:gemfiles"].execute
    Rake::Task["appraisal:install"].execute
    exec('rake appraisal')
  end
end

desc "Run Specs"
RSpec::Core::RakeTask.new(:spec)

desc "Start an IRB session within this plugin"
task :shell do |t|
  chdir File.dirname(__FILE__)
  exec 'irb -I lib/ -I lib/paperclip -r rubygems -r active_record -r tempfile -r init'
end

desc "Clean up files."
task :clean do |t|
  FileUtils.rm_rf "tmp"
  Dir.glob("nilify_blanks-*.gem").each {|f| FileUtils.rm f }
  Dir.glob("spec/db/*.sqlite3").each {|f| FileUtils.rm f }
end
