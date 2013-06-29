require 'extensions/kernel' if defined?(require_relative).nil?
require 'resque'
require 'logger'
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
                  @config = data['config']
                  @job_id = data['job_id']
                  
                end
                
                def run!
                  
                  begin
                    
                    @logger = ::Logger.new(STDOUT)
                    @logger.progname = "JOB \##{@job_id} -- DELEGATE Resque Worker"
                    
                    @logger.info "Running compiler"
                    compile_webblocks @webblocks_dir, @rakefile_config_file_name
                    @logger.info "Compilation complete -- #{@build_dir}"
                    
                    @logger.info "Generating zip of build"
                    zip_directory @build_product, @build_dir
                    @logger.info "Zip of build generated -- #{@build_product}"
                    
                    @logger.info "Writing metadata files"
                    write_metadata_files @metadata_files, @complete_metadata
                    @metadata_files.each { |file| @logger.info "Wrote metadata file -- #{file}" }
                    
                  rescue CommandError => error
                    
                    @logger.fatal "Compiler failed -- #{error.message}"
                    write_error error.message, error.output, error.error
                    return
                    
                  rescue Exception => error
                    
                    @logger.fatal "Build failed -- #{error.message}"
                    write_error error.message
                    return
                    
                  end
                  
                  if @config['workspace_expiration'] == 0
                    file_root = File.dirname File.dirname File.dirname File.dirname File.dirname File.dirname __FILE__
                    Dir.chdir file_root do
                      Dir.chdir "#{@config['workspace_dir']}/#{@config['reference']}" do
                        FileUtils.rm_rf @job_id
                        @logger.info "Removed workspace for completed job"
                      end
                    end
                  end
                  
                end

                def write_error msg, out, err

                  @failed_metadata['error'] = {
                    'message' => msg,
                    'output' => sanitize_message(out),
                    'error' => sanitize_message(err)
                  }

                  @logger.info "Writing metadata files"
                  write_metadata_files @metadata_files, @failed_metadata
                  @metadata_files.each { |file| @logger.info "Wrote metadata file -- #{file}" }

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