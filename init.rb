require 'nilify_blanks'

ActiveRecord::Base.send(:include, Rubiety::NilifyBlanks)