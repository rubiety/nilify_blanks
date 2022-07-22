require "active_support/concern"

module NilifyBlanks
  extend ActiveSupport::Concern

  included do
    class_attribute :nilify_blanks_columns, instance_writer: false, default: []
    class_attribute :nilify_blanks_options, instance_writer: false, default: nil
  end

  module ClassMethods
    DEFAULT_TYPES = [:string, :text, :citext, :hstore]
    DEFAULT_CALLBACK = :validation

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

        options[:before] ||= DEFAULT_CALLBACK
        options[:only] = Array.wrap(options[:only]).map(&:to_s) if options[:only]
        options[:except] = Array.wrap(options[:except]).map(&:to_s) if options[:except]
        options[:types] = options[:types] ? Array.wrap(options[:types]).map(&:to_sym) : DEFAULT_TYPES

        if options[:only]
          columns_to_nilify = options[:only].clone
        elsif options[:nullables_only] == false
          columns_to_nilify = self.columns.select {|c| options[:types].include?(c.type) }.map(&:name).map(&:to_s)
        else
          columns_to_nilify = self.columns.select(&:null).select {|c| options[:types].include?(c.type) }.map(&:name).map(&:to_s)
        end

        columns_to_nilify -= options[:except] if options[:except]

        self.nilify_blanks_columns = columns_to_nilify.map(&:to_s)

        send("before_#{options[:before]}", :nilify_blanks)
      end
    end
  end

  def nilify_blanks
    (nilify_blanks_columns || []).each do |column|
      value = read_attribute(column)

      next unless [String, Array, Hash].include?(value.class)
      next unless value.respond_to?(:blank?)

      write_attribute(column, nilify(value)) if nilifiable? value
    end
  end

  private
    def nilify(value)
      return value unless nilifiable? value

      case value
      when String
        nilify_string(value)
      when Array
        nilify_array(value)
      when Hash
        nilify_hash(value)
      else
        value
      end
    end

    def nilify_string(string)
      nil
    end

    def nilify_array(array)
      return nil if array.empty?

      nilified_array = array.map do |element|
        nilify element
      end.reject(&:blank?)

      nilified_array.empty? ? nil : nilified_array
    end

    def nilify_hash(hash)
      return nil if hash.empty?

      nilified_hash = hash.transform_values do |value|
        nilify value
      end.reject do |_key, value|
        value.blank?
      end

      nilified_hash.empty? ? nil : nilified_hash
    end

    def nilifiable?(value)
      case value
      when String
        nilifiable_string?(value)
      when Array
        nilifiable_array?(value)
      when Hash
        nilifiable_hash?(value)
      when NilClass
        true
      else
        false
      end
    end

    def nilifiable_string?(string)
      string.blank?
    end

    def nilifiable_array?(array)
      return true if array.empty?

      array.any? do |element|
        nilifiable? element
      end
    end

    def nilifiable_hash?(hash)
      return true if hash.empty?

      hash.any? do |_key, value|
        nilifiable? value
      end
    end
end

require "nilify_blanks/railtie"
