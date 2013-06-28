module WebBlocks
  module BuildServer
    module Support
      class Model
        
        attr_accessor :app, :logger
        
        def initialize app, name = false
          
          @app = app
          @logger = Logger.new(STDOUT)
          @logger.progname = "#{name}" if name
          
        end
        
      end
    end
  end
end