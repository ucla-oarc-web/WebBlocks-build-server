module WebBlocks
  module BuildServer
    module Support
      module Job
        
        class DelegateFactory
          
          def initialize job
            @job = job
          end
          
          def build name
            concurrency = @job.app.config['job_concurrency'].capitalize
            load ::File.join( ::File.dirname(__FILE__), "Delegate/#{name}/#{concurrency}.rb" )
            eval("::WebBlocks::BuildServer::Support::Job::Delegate::#{name}::#{concurrency}").new(@job)
          end
          
        end
        
      end
    end
  end
end