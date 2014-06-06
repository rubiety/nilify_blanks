module NilifyBlanks
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def define_attribute_methods
      if super
        define_nilify_blank_methods
      end
    end

    def nilify_blanks(options = {})
      return if self.included_modules.include?(NilifyBlanks::InstanceMethods)

      include NilifyBlanks::InstanceMethods

      @_nilify_blanks_options = options
    end

    private

    def define_nilify_blank_methods
      return unless @_nilify_blanks_options

      options = @_nilify_blanks_options
      options[:only] = Array.wrap(options[:only]).map(&:to_s) if options[:only]
      options[:except] = Array.wrap(options[:except]).map(&:to_s) if options[:except]

      cattr_accessor :nilify_blanks_columns

      if options[:only]
        self.nilify_blanks_columns = options[:only].clone
      else
        self.nilify_blanks_columns = self.content_columns.select(&:null).map(&:name).map(&:to_s)
      end
      self.nilify_blanks_columns -= options[:except] if options[:except]
      self.nilify_blanks_columns = self.nilify_blanks_columns.map(&:to_s)

      options[:before] ||= :save
      send("before_#{options[:before]}", :nilify_blanks)
    end

  end

  module InstanceMethods
    def nilify_blanks
      (self.nilify_blanks_columns || []).each do |column|
        value = read_attribute(column)
        next unless value.is_a?(String)
        next unless value.respond_to?(:blank?)

        write_attribute(column, nil) if value.blank?
      end
    end
  end
end

require "nilify_blanks/railtie"
