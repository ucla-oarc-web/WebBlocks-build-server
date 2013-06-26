require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require_relative 'Base'

module WebBlocks
  module BuildServer
    module Build
      module Strategy
        class SrcSassVariables < Base

          def run! json_data

            data = JSON.parse json_data, { :max_nesting => 1 }
            
            lines = []
            data.each do |key,value|
              lines << "$#{key.gsub(';', '\\;').gsub(':', '\\:')}: #{value.gsub(';', '\\;').gsub(':', '\\:')};"
            end
            
            directory_name = ::File.join(@job.workspace_directory, 'src/sass')
            FileUtils.mkdir_p directory_name
            
            file_name = ::File.join(directory_name, '_variables.scss')
            File.open file_name, 'w' do |f| 
              f.write lines.join "\n"
            end
            @job.logger.info "Saved #{file_name}"

          end

        end
      end
    end
  end
end