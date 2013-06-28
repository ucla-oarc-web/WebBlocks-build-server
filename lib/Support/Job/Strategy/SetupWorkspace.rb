require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require 'json'
require_relative 'Strategy'
require_relative '../../../Model/Job.rb'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Strategy
          
          class SetupWorkspace < Strategy
            
            def run!
              
              FileUtils.mkdir_p @job.path.workspace_directory
              
              @logger.info "Created workspace directory -- #{@job.path.workspace_directory}"
              
              File.open(@job.path.workspace_metadata, 'w') do |f| 
                f.write ::JSON.dump({
                  'status' => ::WebBlocks::BuildServer::Model::Job::MetadataStatus::RUNNING,
                  'id' => @job.id,
                  'build' => @job.app.params,
                  'server' => @job.app.public_config
                })
              end
              
              @job.refresh!
              
              @logger.info "Wrote metadata file -- #{@job.path.workspace_metadata}"
              
            end
            
          end
          
        end
      end
    end
  end
end