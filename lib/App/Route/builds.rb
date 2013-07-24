require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'json'
require 'multi_json'

require_relative "../../Model/Job"

module WebBlocks
  module BuildServer
    class App
      
      get '/builds/:id/zip' do |id|
        
        if @config['allow']['builds_zip']
        
          Support::Builds.with_built_job self, id do |job|
            send_file job.path.build_product, {
              :filename => "WebBlocks.#{id}.zip",
              :type => :zip
            }
          end
          
        else
        
          halt_view 403, "Zip support not available."
          
        end
        
      end
      
      get '/builds/:id/metadata' do |id|
        
        if @config['allow']['builds_metadata']
        
          Support::Builds.with_built_job self, id do |job|
            json job.metadata
          end
        
        else
          
          halt 403, "Metadata support not available."
          
        end
        
      end
      
      get '/builds/:id' do |id|
        
        if @config['allow']['builds_metadata']
        
          Support::Builds.with_built_job self, id do |job|

            renderer = Renderer::Builds.new self

            output = []
            output << "<h2 style=\"font-weight:normal;color:\#777;font-size:1.6em;\"><em>Build \##{id}</em></h2>"
            output << "<h4>Download</h4>"
            output << "<a href=\"#{url("/builds/#{id}/zip")}\">#{url("/builds/#{id}/zip")}</a>"
            output << "<h4>Files</h4>"
            output << "<p>#{renderer.directory_structure_view id, job.path.build_directory}</p>"
            output << "<h4>Metadata</h4>"
            output << "#{renderer.metadata_view job.metadata}"
            raw_view output.join

          end
          
        else
          
          halt_view 403, "Metadata support not available."
          
        end
        
      end
      
      get '/builds/:id/raw' do |id|
        
        redirect "/builds/#{id}", 301
        
      end
      
      get '/builds/:id/raw/*' do |id, relative_path|
        
        if @config['allow']['builds_raw']

          unless relative_path.length > 0 and relative_path.match('..').nil?

            Support::Builds.with_built_job self, id do |job|

              path = File.join job.path.build_directory, relative_path

              cache_control :public
              last_modified File.mtime job.path.build_metadata
              etag File.mtime job.path.build_metadata

              if Dir.exists? path
                redirect "/builds/#{id}", 303
              elsif File.exists? path
                send_file path
              else
                halt_view 404, "Build \##{id} does not contain <span style=\"font-family:'Courier New', Courier, monospace\">#{relative_path}</span>."
              end

            end

          else

            halt_view 400, "Illegal build path specified."

          end
          
        else
          
          halt_view 403, "Raw file support not available"
          
        end
        
      end
      
    end
  end
end
      
require_relative "../Renderer/Builds"
require_relative "../Support/Builds"
