require 'test/unit'
require 'rubygems'
require 'active_record'
require 'active_record/fixtures'
require 'shoulda/rails'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/nilify_blanks'))

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'config', '/database.yml')))
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])

load(File.dirname(__FILE__) + "/schema.rb")

require File.expand_path(File.join(File.dirname(__FILE__), '../init'))