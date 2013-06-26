require 'extensions/kernel' if defined?(require_relative).nil?
require_relative 'Base'

module WebBlocks
  module BuildServer
    module Build
      module Strategy
        class SrcSassBlocks < Base

          def run! data

            directory_name = ::File.join(@job.workspace_directory, 'src/sass')
            FileUtils.mkdir_p directory_name
            
            file_name = ::File.join(directory_name, 'blocks.scss')
            File.open file_name, 'w' do |f| 
              f.write data
            end
            @job.logger.info "Saved #{file_name}"

          end

        end
      end
    end
  end
end