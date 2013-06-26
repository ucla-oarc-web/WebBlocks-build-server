require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require_relative '../Job'

module WebBlocks
  module BuildServer
    module Flush
      class Job < ::WebBlocks::BuildServer::Job

        def initialize app, id, config, logger

          super app, 'Flush', id, config, logger
          
          @cached = [
            workspace_directory,
            build_directory,
            build_product,
            build_metadata
          ]

        end
        
        # Job is complete if no cached files
        def complete?
          @cached.none? { |item| File.exists? item }
        end

        def run!
          if complete?
            {
              'id'=>@id, 
              'status'=>::WebBlocks::BuildServer::Status::MISSING
            }
          else
            @cached.each { |item| FileUtils.rm_rf item }
            {
              'id'=>@id, 
              'status'=>::WebBlocks::BuildServer::Status::DONE
            }
          end
        end
        
      end
    end
  end
end