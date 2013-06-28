module WebBlocks
  module BuildServer
    module Support
      module Job
        module Delegate
        
          class Delegate
            
            def initialize job
              
              @job = job
              @logger = Logger.new(STDOUT)
              
              name = self.class.name
              if i = name.rindex('::')
                name = name[(i+2)..-1]
              end
              
              @logger.progname = "#{job.logger.progname} -- DELEGATE #{name}"
              
            end
            
            def run!
              @logger.warn "Delegate process run! method is not defined"
            end
            
          end
          
        end
      end
    end
  end
end