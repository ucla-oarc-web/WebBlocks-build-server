require 'extensions/kernel' if defined?(require_relative).nil?
require 'systemu'

require_relative 'CommandError'
require_relative '../../with_clean_bundler_env'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Command
          
          def compile_webblocks webblocks_directory, rakefile_config_path
            
            Dir.chdir(webblocks_directory) do 
              ::WebBlocks::BuildServer::Support.with_clean_bundler_env do

                status, stdout, stderr = systemu "bundle"
                raise CommandError.new("Failed to initialize bundler", stdout, stderr) if stderr.length > 0

                command = "rake -- --config=#{rakefile_config_path}"
                
                status, stdout, stderr = systemu command
                raise CommandError.new("Failed to complete compiler run", stdout, stderr) if stderr.length > 0

              end
            end
            
          end
        end
      end
    end
  end
end