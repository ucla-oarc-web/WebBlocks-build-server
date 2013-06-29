require 'extensions/kernel' if defined?(require_relative).nil?
require 'resque'
require_relative 'Base'
require_relative '../../Command/CommandError'
require_relative '../../Command/compile_webblocks'
require_relative '../../Command/write_metadata_files'
require_relative '../../Command/zip_directory'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Delegate
          module ExecuteBuild
            class Resque < Base
              
              def run!
                
                ::Resque.enqueue(self.class, self.to_hash)

              end

              @queue = "job"
              
              def self.perform(data)
                
                Worker.new(data).run!
                
              end
              
              class Worker
              
                include ::WebBlocks::BuildServer::Support::Job::Command
                
                def initialize data
                  
                  @webblocks_dir = data['webblocks_dir']
                  @rakefile_config_file_name = data['rakefile_config_file_name']
                  @build_dir = data['build_dir']
                  @build_product = data['build_product']
                  @metadata_files = data['metadata_files']
                  @complete_metadata = data['complete_metadata']
                  @failed_metadata = data['failed_metadata']
                  
                end
                
                def run!
                  
                  begin
                    
                    puts "Running compiler"
                    compile_webblocks @webblocks_dir, @rakefile_config_file_name
                    puts "Compilation complete -- #{@build_dir}"
                    
                    puts "Generating zip of build"
                    zip_directory @build_product, @build_dir
                    puts "Zip of build generated -- #{@build_product}"
                    
                    puts "Writing metadata files"
                    write_metadata_files @metadata_files, @complete_metadata
                    @metadata_files.each { |file| puts "Wrote metadata file -- #{file}" }
                    
                  rescue CommandError => error
                    
                    puts "Compiler failed -- #{error.message}"
                    write_error error.message, error.output, error.error
                    return
                    
                  rescue Exception => error
                    
                    puts "Build failed -- #{error.message}"
                    write_error error.message
                    return
                    
                  end
                  
                end

                def write_error msg, out, err

                  @failed_metadata['error'] = {
                    'message' => msg,
                    'output' => sanitize_message(out),
                    'error' => sanitize_message(err)
                  }

                  puts "Writing metadata files"
                  write_metadata_files @metadata_files, @failed_metadata
                  @metadata_files.each { |file| puts "Wrote metadata file -- #{file}" }

                end

                def sanitize_message message
                  root = File.dirname File.dirname File.dirname File.dirname File.dirname __FILE__
                  message.gsub /#{root}\/*/, ''
                end
                
              end
              
            end
          end
        end
      end
    end
  end
end