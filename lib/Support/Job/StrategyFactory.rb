module WebBlocks
  module BuildServer
    module Support
      module Job
        
        USER_STRATEGIES = {
          'rakefile-config' => 'SetupRakefileConfig',
          'src-sass-variables' => 'SetupSrcSassVariables',
          'src-sass-blocks' => 'SetupSrcSassBlocks',
          'src-sass-blocks-ie' => 'SetupSrcSassBlocksIe'
        }
        
        CORE_STRATEGIES = {
          'setup' => 'SetupWorkspace',
          'execute' => 'ExecuteBuild'
        }
        
        class StrategyFactory 
          
          def initialize job
            @job = job
          end
          
          def build job, name
            strategies = (USER_STRATEGIES.merge(CORE_STRATEGIES))
            if strategies.has_key? name
              class_name = strategies[name]
              load ::File.join( ::File.dirname(__FILE__), "Strategy/#{class_name}.rb" )
              eval("WebBlocks::BuildServer::Support::Job::Strategy::#{class_name}").new(job)
            else
              nil
            end
          end
          
          def build_each
            
            strategy_names = USER_STRATEGIES.keys
            strategy_names.unshift 'setup'
            strategy_names.push 'execute'
            
            strategies = []
            strategy_names.each do |strategy_name|
              strategy = build @job, strategy_name
              strategies << strategy if strategy
            end
            
            if block_given?
              strategies.each do |strategy|
                yield strategy
              end
            end
            
            strategies
            
          end
        end
        
      end
    end
  end
end