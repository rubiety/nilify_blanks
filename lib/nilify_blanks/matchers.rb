rspec_module = defined?(RSpec::Core) ? 'RSpec' : 'Spec'  # for RSpec 1 compatability

def failure_message_method
  rspec_major_version >= 3 ? :failure_message : :failure_message_for_should
rescue
  :failure_message_for_should
end

def negated_failure_message_method
  rspec_major_version >= 3 ? :failure_message_when_negated : :failure_message_for_should_not
rescue
  :failure_message_for_should_not
end

def rspec_major_version
  RSpec::Core::Version::STRING.split('.').first.to_i
end

Kernel.const_get(rspec_module)::Matchers.define :nilify_blanks_for do |column_name, options = {}|
  match do |model_instance|
    model_class = model_instance.class
    model_class.define_attribute_methods
    model_class.included_modules.include?(NilifyBlanks::InstanceMethods) &&
    model_class.respond_to?(:nilify_blanks_columns) &&
    model_class.nilify_blanks_columns.include?(column_name.to_s) &&
    options.all? {|k, v| model_class.instance_variable_get(:@_nilify_blanks_options)[k] == v }
  end

  send(failure_message_method) do |_|
    "expected to nilify blanks for #{column_name} #{options.inspect unless options.empty?}"
  end

  send(negated_failure_message_method) do |_|
    "expected to not nilify blanks for #{column_name} #{options.inspect unless options.empty?}"
  end
end

Kernel.const_get(rspec_module)::Matchers.define :nilify_blanks do |options = {}|
  match do |model_instance|
    options[:types] = options[:types] ? Array.wrap(options[:types]).map(&:to_sym) : NilifyBlanks::ClassMethods::DEFAULT_TYPES

    model_class = model_instance.class
    model_class.define_attribute_methods
    model_class.included_modules.include?(NilifyBlanks::InstanceMethods) &&
    model_class.respond_to?(:nilify_blanks_columns) &&
    model_class.nilify_blanks_columns == model_class.content_columns.select(&:null).select {|c| options[:types].include?(c.type) }.map(&:name).map(&:to_s) &&
    options.all? {|k, v| model_class.instance_variable_get(:@_nilify_blanks_options)[k] == v }
  end

  send(failure_message_method) do |_|
    "expected to nilify blanks #{options.inspect unless options.empty?}"
  end

  send(negated_failure_message_method) do |_|
    "expected to not nilify blanks #{options.inspect unless options.empty?}"
  end
end
