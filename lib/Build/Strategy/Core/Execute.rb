require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require_relative '../Base'
require_relative '../../../Support/with_clean_bundler_env'

module WebBlocks
  module BuildServer
    module Build
      module Strategy
        module Core
          class Execute < ::WebBlocks::BuildServer::Build::Strategy::Base

            def run! data
              
              build_tmp_dir = @job.workspace_build_tmp_directory.gsub("\"","\\\"")
              build_dir = @job.build_directory.gsub("\"","\\\"")
              src_dir = ::File.join(@job.workspace_directory, 'src').gsub("\"","\\\"")
              src_adapter_dir = @job.webblocks_src_adapter_directory.gsub("\"","\\\"")
              src_core_dir = @job.webblocks_src_core_directory.gsub("\"","\\\"")
              src_extension_dir = @job.webblocks_src_extension_directory.gsub("\"","\\\"")
              
              FileUtils.mkdir_p src_dir
              
              rakefile_config_file_name = ::File.join(@job.workspace_directory, 'Rakefile-config.rb')
              File.open rakefile_config_file_name, 'a' do |f| 
                f.write "\nWebBlocks.config[:build][:dir_tmp] = \"#{build_tmp_dir}\";"
                f.write "\nWebBlocks.config[:build][:dir] = \"#{build_dir}\";"
                f.write "\nWebBlocks.config[:src][:dir] = \"#{src_dir}\";"
                f.write "\nWebBlocks.config[:src][:core][:dir] = \"#{src_core_dir}\";"
                f.write "\nWebBlocks.config[:src][:adapters][:dir] = \"#{src_adapter_dir}\";"
                f.write "\nWebBlocks.config[:src][:extension][:dir] = \"#{src_extension_dir}\""
              end
              @job.logger.info "Appended #{rakefile_config_file_name}"
              
              @job.logger.info "Dispatching build thread"
              
              fork do
                Dir.chdir(@job.webblocks_directory) do 
                  ::WebBlocks::BuildServer::Support.with_clean_bundler_env do
                    
                    logger = @job.logger.clone
                    logger.progname << " -- Build Process"
                    
                    # this should already be initialized so just need to ensure env
                    logger.info "Initialize bundler"
                    status, stdout, stderr = systemu "bundle"
                    if stderr.length > 0
                      logger.fatal "Failed to initialize bundler"
                      # write out some metadata about why the build failed
                      exit!
                    end
                    
                    command = "rake -- --config=#{rakefile_config_file_name}"
                    logger.info "Run build [ #{command} ]"
                    status, stdout, stderr = systemu command
                    if stderr.length > 0
                      logger.fatal "Failed to run build"
                      logger.fatal stderr
                      # write out some metadata about why the build failed
                      exit!
                    end
                    
                    logger.info "Build complete"
                    
                  end
                end
              end
              
              @job.logger.debug "Forked process to run WebBlocks build"
              
            end

          end
        end
      end
    end
  end
end