require "rubygems"
require "rake"
require "rake/rdoctask"

desc "Generate documentation for the plugin."
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.title    = "nilify_blanks"
  rdoc.options << "--line-numbers" << "--inline-source"
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Dir["#{File.dirname(__FILE__)}/lib/tasks/*.rake"].sort.each { |ext| load ext }
