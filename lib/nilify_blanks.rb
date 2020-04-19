module NilifyBlanks
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    DEFAULT_TYPES = [:string, :text, :citext]

    @@define_nilify_blank_methods_lock = Mutex.new

    # This overrides the underlying rails method that defines attribute methods.
    # This must be thread safe, just like the underlying method.
    #
    def define_attribute_methods
      if super
        define_nilify_blank_methods
      end
    end

    def inherited(child_class)
      if instance_variable_get(:@_nilify_blanks_options) and !child_class.instance_variable_get(:@_nilify_blanks_options)
        child_class.nilify_blanks @_nilify_blanks_options
      end

      super
    end

    def nilify_blanks(options = {})
      return if @_nilify_blanks_options

      unless included_modules.include?(NilifyBlanks::InstanceMethods)
        include NilifyBlanks::InstanceMethods
      end

      @_nilify_blanks_options = options

      # Normally we wait for rails to define attribute methods, but we could be calling this after this has already been done.
      # If so, let's just immediately generate nilify blanks methods.
      #
      if @attribute_methods_generated
        define_nilify_blank_methods
      end

      descendants.each do |subclass|
        subclass.nilify_blanks @_nilify_blanks_options
      end
    end


    private

    def define_nilify_blank_methods
      return unless @_nilify_blanks_options
      return if @nilify_blanks_methods_generated

      @@define_nilify_blank_methods_lock.synchronize do
        return if @nilify_blanks_methods_generated

        options = @_nilify_blanks_options

        options[:only] = Array.wrap(options[:only]).map(&:to_s) if options[:only]
        options[:except] = Array.wrap(options[:except]).map(&:to_s) if options[:except]
        options[:types] = options[:types] ? Array.wrap(options[:types]).map(&:to_sym) : DEFAULT_TYPES

        cattr_accessor :nilify_blanks_columns

        if options[:only]
          self.nilify_blanks_columns = options[:only].clone
        elsif options[:nullables_only] == false
          self.nilify_blanks_columns = self.columns.select {|c| options[:types].include?(c.type) }.map(&:name).map(&:to_s)
        else
          self.nilify_blanks_columns = self.columns.select(&:null).select {|c| options[:types].include?(c.type) }.map(&:name).map(&:to_s)
        end

        self.nilify_blanks_columns -= options[:except] if options[:except]
        self.nilify_blanks_columns = self.nilify_blanks_columns.map(&:to_s)

        options[:before] ||= :save
        send("before_#{options[:before]}", :nilify_blanks)
        @nilify_blanks_methods_generated = true
      end
    end
  end

  module InstanceMethods
    def nilify_blanks
      (self.nilify_blanks_columns || []).each do |column|
        value = read_attribute(column)
        next unless value.is_a?(String) || value.is_a?(Array)
        next unless value.respond_to?(:blank?)
        if value.is_a?(Array) # for pg array
          value.reject!(&:blank?)
          write_attribute(column, []) and next if value.blank?
        end

        write_attribute(column, nil) if value.blank?
      end
    end
  end
end

require "nilify_blanks/railtie"
