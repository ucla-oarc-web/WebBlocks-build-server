require 'extensions/kernel' if defined?(require_relative).nil?
require_relative 'Base'
require_relative '../../Command/CommandError'
require_relative '../../Command/compile_webblocks'
require_relative '../../Command/write_metadata_files'
require_relative '../../Command/zip_directory'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Delegate
          module ExecuteBuild
            class Fork < Base
              
              include ::WebBlocks::BuildServer::Support::Job::Command
              
              def run!
                
                pid = fork do
                  
                  begin
                    
                    @logger.info "Running compiler"
                    compile_webblocks @webblocks_dir, @rakefile_config_file_name
                    @logger.info "Compilation complete -- #{@build_dir}"
                    
                    @logger.info "Generating zip of build"
                    zip_directory @build_product, @build_dir
                    @logger.info "Zip of build generated -- #{@build_product}"
                    
                    @logger.info "Writing metadata files"
                    write_metadata_files @metadata_files, @complete_metadata
                    @metadata_files.each { |file| @logger.info "Wrote metadata file -- #{file}" }
                    
                  rescue CommandError => error
                    
                    @logger.fatal "Compiler failed -- #{error.message}"
                    write_error error.message, error.output, error.error
                    
                  rescue Exception => error
                    
                    @logger.fatal "Build failed -- #{error.message}"
                    write_error error.message
                    
                  end

                end
                
                if pid
                  @job.app.add_resource_pool_child_pid pid
                  @logger.debug "Forked for build process -- pid #{pid}"
                end

              end
              
            end
          end
        end
      end
    end
  end
end