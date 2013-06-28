require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require_relative 'Strategy'
require_relative '../Delegate/ExecuteBuild'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Strategy
          
          class ExecuteBuild < Strategy
            
            def run!
              
              build_tmp_dir = @job.path.workspace_build_tmp_directory.gsub("\"","\\\"")
              build_dir = @job.path.build_directory.gsub("\"","\\\"")
              src_dir = ::File.join(@job.path.workspace_directory, 'src').gsub("\"","\\\"")
              src_adapter_dir = @job.path.webblocks_src_adapter_directory.gsub("\"","\\\"")
              src_core_dir = @job.path.webblocks_src_core_directory.gsub("\"","\\\"")
              src_extension_dir = @job.path.webblocks_src_extension_directory.gsub("\"","\\\"")
              rakefile_config_file_name = ::File.join(@job.path.workspace_directory, 'Rakefile-config.rb')
              
              FileUtils.mkdir_p src_dir
              
              File.open rakefile_config_file_name, 'a' do |f| 
                f.write "\nWebBlocks.config[:build][:dir_tmp] = \"#{build_tmp_dir}\";"
                f.write "\nWebBlocks.config[:build][:dir] = \"#{build_dir}\";"
                f.write "\nWebBlocks.config[:src][:dir] = \"#{src_dir}\";"
                f.write "\nWebBlocks.config[:src][:core][:dir] = \"#{src_core_dir}\";"
                f.write "\nWebBlocks.config[:src][:adapters][:dir] = \"#{src_adapter_dir}\";"
                f.write "\nWebBlocks.config[:src][:extension][:dir] = \"#{src_extension_dir}\""
              end
              @logger.info "Appended #{rakefile_config_file_name}"
              
              @logger.info "Dispatching delegate"
              ::WebBlocks::BuildServer::Support::Job::Delegate::ExecuteBuild.new(@job).run!
              @logger.info "Delegate dispatched"
              
            end
            
          end
          
        end
      end
    end
  end
end