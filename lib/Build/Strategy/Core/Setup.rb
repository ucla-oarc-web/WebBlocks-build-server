require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require 'json'
require_relative '../Base'

module WebBlocks
  module BuildServer
    module Build
      module Strategy
        module Core
          class Setup < ::WebBlocks::BuildServer::Build::Strategy::Base

            def run! data

              FileUtils.mkdir_p @job.workspace_directory
              File.open(@job.workspace_metadata, 'w') do |f| 
                f.write ::JSON.dump({
                  'status' => 'running',
                  'server' => @job.app.public_config,
                  'build' => @job.params
                })
              end
              @job.logger.info "Wrote metadata file -- #{@job.workspace_metadata}"

            end

          end
        end
      end
    end
  end
end