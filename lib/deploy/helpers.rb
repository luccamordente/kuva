def say text
  `if [ -s /usr/bin/say ]; then say "#{text}"; fi`
end

module Capistrano
  class CLI
    module UI
      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      module ClassMethods
        
        alias_method :password_prompt_original, :password_prompt
        
        def say text
          `if [ -s /usr/bin/say ]; then say "#{text}"; fi`
        end
        
        def password_prompt *args
          say "Password?" 
          password_prompt_original *args
        end
        
      end
      
    end
    
    include UI
    
  end
end
