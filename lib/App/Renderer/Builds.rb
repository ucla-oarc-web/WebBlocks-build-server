require 'extensions/kernel' if defined?(require_relative).nil?
require_relative '../builds'

module WebBlocks
  module BuildServer
    class App
      
      module Renderer
      
        class Builds
          
          def initialize app
            @app = app
          end

          def directory_structure_view id, real_path, relative_path = ''

            files = []
            files << "<a href=\".\">.. <em>(up one directory)</em></a>" if relative_path.length > 0
            Dir[File.join(real_path, '**', '**')].each do |file|
              next if File.directory? file and Dir[File.join file, '*'].length == 0
              relative_file_path = file.sub(real_path, '').gsub(/^\//,'')
              match = relative_file_path.match('/')
              file_str = "#{"&nbsp; " * (match.nil? ? 0 : match.length)} #{match.nil? ? '' : '&#8627;'}"
              if File.file? file
                file_str << "<a href=\"#{@app.url("/builds/#{id}/raw#{relative_path.length > 0 ? "/#{relative_path}" : ''}/#{relative_file_path}")}\">"
              end
              file_str << File.basename(file)
              if File.file? file
                file_str << "</a>"
              end
              files << file_str
            end

            files.join '<br>'

          end

          def metadata_view metadata

            entries = []
            metadata.each do |key, value|
              entries << "<div class=\"row\"><div class=\"panel-2\"><p><strong>#{key}</strong></p></div><div class=\"panel-10\" style=\"font-family:'Courier New', Courier, monospace\">#{metadata_sub_view value}</div></div>"
            end

            entries.join

          end

          def metadata_sub_view metadata

            if metadata.is_a? Hash
              entries = []
              metadata.each do |key, value|
                entries << "<p>#{key}<br><pre style=\"font-family:'Courier New', Courier, monospace\">#{value}</pre></p>"
              end

              entries.join
            else
              "<p>#{metadata}</p>"
            end

          end

        end
        
      end
      
    end
  end
end
