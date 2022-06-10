require "rubygems"
require "rspec"
require "active_support"
require "active_record"
require "yaml"

# Establish DB Connection
config = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), 'db', 'database.yml.erb'))).result)
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'sqlite3']}

test_config =
  if ActiveRecord::VERSION::MAJOR == 7
    ActiveRecord::Base.configurations.find_db_config('test')
  else
    ActiveRecord::Base.configurations['test']
  end

ActiveRecord::Base.establish_connection(test_config)

# Load Test Schema into the Database
load(File.dirname(__FILE__) + "/db/schema.rb")

require File.dirname(__FILE__) + '/../init'

RSpec.configure do |config|
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true unless meta.key?(:aggregate_failures)
  end

  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"

  # config.order = :random
  # Kernel.srand config.seed

  # config.warnings = true
end
