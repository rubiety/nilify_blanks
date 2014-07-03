rspec_module = defined?(RSpec::Core) ? 'RSpec' : 'Spec'  # for RSpec 1 compatability
Kernel.const_get(rspec_module)::Matchers.define :nilify_blanks_for do |column_name|
  match do |model_instance|
    model_class = model_instance.class
    model_class.define_attribute_methods
    model_class.included_modules.include?(NilifyBlanks::InstanceMethods) &&
    model_class.respond_to?(:nilify_blanks_columns) &&
    model_class.nilify_blanks_columns.include?(column_name.to_s)
  end

  failure_message_for_should do |ability|
    "expected to nilify blanks for #{column_name}"
  end

  failure_message_for_should_not do |ability|
    "expected to not nilify blanks for #{column_name}"
  end
end

