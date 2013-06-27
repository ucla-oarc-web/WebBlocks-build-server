require 'extensions/kernel' if defined?(require_relative).nil?
require_relative "Status"

module WebBlocks
  module BuildServer
    class Job
      
      attr_accessor :app, :name, :id, :config, :logger

      def initialize app, name, id, config, logger

        @app = app
        @name = name
        @id = id
        @config = config
        @logger = logger
        @logger.progname = "Job \##{@id} -- #{name}"
        @logger.info "Initialize #{self}"

      end
      
      def end!
        
        @logger.info "End #{self}"
        
      end

      # Workspace for WebBlocks build
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
      
      def complete?
        true # this should be overridden by job implementations
      end
      
    end
  end
end