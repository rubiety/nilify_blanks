class ExceptPost < ActiveRecord::Base
  set_table_name :posts
  
  nilify_blanks :except => [:first_name, :title]
end
