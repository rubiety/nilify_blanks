class OnlyPost < ActiveRecord::Base
  set_table_name :posts
  
  nilify_blanks :only => [:first_name, :title]
end
