require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require_relative 'Strategy'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Strategy
          
          class SetupSrcSassBlocksIe < Strategy
            
            def run!
              
              data = @job.app.params.include?('src-sass-blocks-ie') ? @job.app.params['src-sass-blocks-ie'] : ''
              
              directory_name = ::File.join(@job.path.workspace_directory, 'src/sass')
              FileUtils.mkdir_p directory_name

              file_name = ::File.join(directory_name, 'blocks-ie.scss')
              File.open file_name, 'w' do |f| 
                f.write '@import "WebBlocks-ie"; '
                f.write data
              end
              
              @logger.info "Saved #{file_name}"
              
            end
            
          end
          
        end
      end
    end
  end
end