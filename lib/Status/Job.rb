require 'extensions/kernel' if defined?(require_relative).nil?
require_relative '../Job'

module WebBlocks
  module BuildServer
    module Status
      class Job < ::WebBlocks::BuildServer::Job

        def initialize app, id, config, logger

          super app, 'Status', id, config, logger
          
        end

        def run!
          
          if File.exist? build_metadata
            status = ::WebBlocks::BuildServer::Status::DONE
          elsif File.exist? workspace_metadata
            status = ::WebBlocks::BuildServer::Status::RUNNING
          else
            status = ::WebBlocks::BuildServer::Status::MISSING
          end

          {
            'id'=>@id, 
            'status'=>status
          }
        
        end
      end
    end
  end
end