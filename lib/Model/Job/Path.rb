require 'extensions/kernel' if defined?(require_relative).nil?
require_relative '../Job'

module WebBlocks
  module BuildServer
    module Model
      class Job
        
        class Path
          
          def initialize job
            @id = job.id
            @config = job.app.config
          end
          
          def to_hash
            hash = {}
            (self.class.instance_methods - Object.methods - ['to_hash','initialize']).each do |method|
              hash[method] = send(method)
            end
            hash
          end
          
          def webblocks_directory
            ::File.join( @config['workspace_dir'], "#{@config['reference']}", '_WebBlocks' )
          end

          def webblocks_src_adapter_directory
            ::File.join( webblocks_directory, "src/adapter" )
          end

          def webblocks_src_core_directory
            ::File.join( webblocks_directory, "src/core" )
          end

          def webblocks_src_extension_directory
            ::File.join( webblocks_directory, "src/extension" )
          end

          # Workspace for WebBlocks build
          def workspace_directory
            ::File.join( @config['workspace_dir'], "#{@config['reference']}", @id )
          end

          def workspace_build_tmp_directory
            ::File.join( workspace_directory, '.build-tmp' )
          end

          def workspace_metadata
            ::File.join( workspace_directory, 'metadata.json' )
          end

          # Build directory for completed WebBlocks build for job
          def build_directory
            ::File.join( @config['build_dir'], "#{@config['reference']}", @id )
          end

          # Compressed version of the /build directory within build_directory
          def build_product
            ::File.join( @config['build_dir'], "#{@config['reference']}", "WebBlocks.#{@id}.zip" )
          end

          # File created once complete that contains metadata about build
          def build_metadata
            ::File.join( @config['build_dir'], "#{@config['reference']}", "WebBlocks.#{@id}.json" )
          end
          
        end
        
      end
    end
  end
end