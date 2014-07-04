module NilifyBlanks
  if defined?(Rails::Railtie)
    require "rails"
    
    class Railtie < Rails::Railtie
      initializer "nilify_blanks.extend_active_record" do
        ActiveSupport.on_load(:active_record) do
          NilifyBlanks::Railtie.insert
        end
      end
    end
  end
  
  class Railtie
    def self.insert
      ActiveRecord::Base.send(:include, NilifyBlanks)
    end
  end
end
