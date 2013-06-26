require 'extensions/kernel' if defined?(require_relative).nil?
require 'json'

require_relative '../Job'

module WebBlocks
  module BuildServer
    module Build
      class Job < ::WebBlocks::BuildServer::Job

        attr_accessor :params

        def initialize app, params, config, logger
          
          super app, 'Build', Digest::MD5.hexdigest(params.to_s), config, logger

          @params = params

          @strategies = {
            'rakefile-config' => 'RakefileConfig',
            'src-sass-variables' => 'SrcSassVariables',
            'src-sass-blocks' => 'SrcSassBlocks',
            'src-sass-blocks-ie' => 'SrcSassBlocksIe'
          }

        end
        
        def started?
          File.exist? workspace_metadata
        end

        # Job is complete if metadata exists for the build file
        def complete?
          File.exist? build_metadata
        end

        def run!
          unless complete?
            unless started?
              run_core_strategy! 'Setup'
              @params.each { |name, data| run_user_strategy! name, data }
              run_core_strategy! 'Execute'
            end
            status = ::WebBlocks::BuildServer::Status::RUNNING
          else
            status = ::WebBlocks::BuildServer::Status::DONE
          end
          
          {
            'id'=>@id, 
            'status'=>status
          }
        end

        def run_strategy! name, strategy, data = nil
          if strategy.respond_to? 'run!'
            strategy.run! data
          else
            @logger.warn "Skip strategy '#{name}' -- Method run! does not exist on #{self}"
          end
        end

        def run_core_strategy! name
          load ::File.join( ::File.dirname(__FILE__), "Strategy/Core/#{name}.rb" )
          strategy = eval("WebBlocks::BuildServer::Build::Strategy::Core::#{name}").new(self)
          @logger.debug "Initialize strategy #{strategy} for '#{name}'"
          run_strategy! name, strategy
        end

        def run_user_strategy! name, data
          if @strategies.has_key? name
            load ::File.join( ::File.dirname(__FILE__), "Strategy/#{@strategies[name]}.rb" )
            strategy = eval("WebBlocks::BuildServer::Build::Strategy::#{@strategies[name]}").new(self)
            @logger.debug "Initialize strategy '#{name}' -- #{strategy}"
            run_strategy! name, strategy, data
          else
            @logger.warn "Skip strategy '#{name}' -- Does not exist"
          end
        end
        
      end
    end
  end
end