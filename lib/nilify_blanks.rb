require "active_support/concern"

module NilifyBlanks
  extend ActiveSupport::Concern

  included do
    class_attribute :nilify_blanks_columns, instance_writer: false, default: []
    class_attribute :nilify_blanks_options, instance_writer: false, default: nil
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

    def nilify_blanks(options = {})
      self.nilify_blanks_options = options

      # Normally we wait for rails to define attribute methods, but we could be calling this after this has already been done.
      # If so, let's just immediately generate nilify blanks methods.
      #
      define_nilify_blank_methods if @attribute_methods_generated
    end


    private

    def define_nilify_blank_methods
      return unless nilify_blanks_options

      @@define_nilify_blank_methods_lock.synchronize do
        options = nilify_blanks_options.dup
        options[:only] = Array.wrap(options[:only]).map(&:to_s) if options[:only]
        options[:except] = Array.wrap(options[:except]).map(&:to_s) if options[:except]
        options[:types] = options[:types] ? Array.wrap(options[:types]).map(&:to_sym) : DEFAULT_TYPES

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
      end
    end
  end

  def nilify_blanks
    (nilify_blanks_columns || []).each do |column|
      value = read_attribute(column)
      next unless value.is_a?(String)
      next unless value.respond_to?(:blank?)

      write_attribute(column, nil) if value.blank?
    end
  end
end

require "nilify_blanks/railtie"
