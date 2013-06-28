require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require_relative 'Strategy'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Strategy
          
          class SetupSrcSassVariables < Strategy
            
            def run!

              json_data = @job.app.params.include?('src-sass-variables') ? @job.app.params['src-sass-variables'] : '{}'
              
              data = nil
              begin
                data = JSON.parse(json_data, { :max_nesting => 1 })
              rescue
              end
              data = {} if data.nil?

              lines = []
              data.each do |key,value|
                lines << "$#{key.gsub(';', '\\;').gsub(':', '\\:')}: #{value.gsub(';', '\\;').gsub(':', '\\:')};"
              end

              directory_name = ::File.join(@job.path.workspace_directory, 'src/sass')
              FileUtils.mkdir_p directory_name

              file_name = ::File.join(directory_name, '_variables.scss')
              File.open file_name, 'w' do |f| 
                f.write lines.join "\n"
              end
              
              @logger.info "Saved #{file_name}"
              
            end
            
          end
          
        end
      end
    end
  end
end