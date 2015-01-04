require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rspec/core/rake_task'

desc 'Default: run unit tests.'
task :default => [:clean, :test]

desc "Run Specs"
RSpec::Core::RakeTask.new(:spec) do |t|
end

task :test => :spec

desc "Clean up files."
task :clean do |t|
  FileUtils.rm_rf "tmp"
  Dir.glob("nilify_blanks-*.gem").each {|f| FileUtils.rm f }
  Dir.glob("spec/db/*.sqlite3").each {|f| FileUtils.rm f }
end

begin
  require 'rdoc/task'

  desc "Generate documentation for the plugin."
  Rake::RDocTask.new(:rdoc) do |rdoc|
    rdoc.rdoc_dir = "rdoc"
    rdoc.title    = "nilify_blanks"
    rdoc.options << "--line-numbers" << "--inline-source"
    rdoc.rdoc_files.include('README')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError
  puts 'RDocTask is not supported for this platform'
end

Dir["#{File.dirname(__FILE__)}/lib/tasks/*.rake"].sort.each { |ext| load ext }

