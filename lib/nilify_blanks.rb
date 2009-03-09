module Rubiety
  module NilifyBlanks
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def nilify_blanks(options = {})
        return if self.included_modules.include?(NilifyBlanks::InstanceMethods)
        include NilifyBlanks::InstanceMethods
        
        if options[:only]
          options[:only] = [options[:only]] unless options[:only].is_a?(Array)
          options[:only] = options[:only].map(&:to_s)
        end
        
        if options[:except]
          options[:except] = [options[:except]] unless options[:except].is_a?(Array)
          options[:except] = options[:except].map(&:to_s)
        end
        
        cattr_accessor :nilify_blanks_columns
        
        self.nilify_blanks_columns = self.content_columns.reject {|c| !c.null }.map {|c| c.name.to_s }
        self.nilify_blanks_columns = self.nilify_blanks_columns.select {|c| options[:only].include?(c) } if options[:only]
        self.nilify_blanks_columns -= options[:except] if options[:except]
        self.nilify_blanks_columns = self.nilify_blanks_columns.map(&:to_s)
        
        options[:before] ||= :save
        class_eval "before_#{options[:before]} :nilify_blanks"
      end
    end
    
    module InstanceMethods
      def nilify_blanks
        (self.nilify_blanks_columns || []).each do |column|
          value = read_attribute(column)
          next unless value.is_a?(String)
          next unless value.nil? or !value.respond_to?(:blank)
          
          write_attribute(column, nil) if value.blank?
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Rubiety::NilifyBlanks)