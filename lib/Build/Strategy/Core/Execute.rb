require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require_relative '../Base'

module WebBlocks
  module BuildServer
    module Build
      module Strategy
        module Core
          class Execute < ::WebBlocks::BuildServer::Build::Strategy::Base

            def run! data
              
              build_dir = @job.build_directory.gsub("\"","\\\"")
              src_dir = ::File.join(@job.workspace_directory, 'src/sass').gsub("\"","\\\"")
              src_adapter_dir = @job.webblocks_src_adapter_directory.gsub("\"","\\\"")
              src_core_dir = @job.webblocks_src_core_directory.gsub("\"","\\\"")
              
              FileUtils.mkdir_p src_dir
              
              file_name = ::File.join(@job.workspace_directory, 'Rakefile-config.rb')
              File.open file_name, 'a' do |f| 
                f.write "\nWebBlocks.config[:build][:dir] = \"#{build_dir}\";"
                f.write "\nWebBlocks.config[:src][:dir] = \"#{src_dir}\";"
                f.write "\nWebBlocks.config[:src][:core][:dir] = \"#{src_adapter_dir}\";"
                f.write "\nWebBlocks.config[:src][:adapters][:dir] = \"#{src_core_dir}\";"
              end
              @job.logger.info "Appended #{file_name}"
              
              @job.logger.info "Dispatching process"

            end

          end
        end
      end
    end
  end
end