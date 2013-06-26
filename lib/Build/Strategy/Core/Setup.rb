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
              File.open(@job.workspace_metadata, 'w') { |f| f.write(::JSON.dump @job.params) }

            end

          end
        end
      end
    end
  end
end