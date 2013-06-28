module WebBlocks
  module BuildServer
    module Support
      module Job
        module Strategy
        
          class Strategy
            
            def initialize job
              @job = job
              @logger = Logger.new(STDOUT)
              
              name = self.class.name
              if i = name.rindex('::')
                name = name[(i+2)..-1]
              end
              
              @logger.progname = "#{job.logger.progname} -- STRATEGY #{name}"
              
            end
            
            def run!
              @logger.warn "Strategy run! method is not defined"
            end
            
          end
          
        end
      end
    end
  end
end