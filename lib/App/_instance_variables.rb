require 'extensions/kernel' if defined?(require_relative).nil?
require_relative "../App"

module WebBlocks
  module BuildServer
    class App
      
      attr_accessor :public_config
      attr_accessor :config
      attr_accessor :logger
      
      before do
        
        @public_config = settings.public_config
        @config = settings.config
        @logger = Logger.new(STDOUT)
        
      end
      
    end
  end
end




      