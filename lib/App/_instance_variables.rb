require 'extensions/kernel' if defined?(require_relative).nil?
require_relative "../App"

module WebBlocks
  module BuildServer
    class App
      
      attr_accessor :public_config
      attr_accessor :config
      attr_accessor :logger
      
      def attach_instance_variables!
        
        @public_config = settings.public_config
        @config = settings.config
        @logger = Logger.new(STDOUT)
        
      end
      
      before do
        
        attach_instance_variables!
        
      end
      
    end
  end
end




      