require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'zip/zip'
require 'json'
require_relative 'Delegate'
require_relative '../../with_clean_bundler_env'
require_relative '../../../Model/Job.rb'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Delegate
          
          class ExecuteBuild < Delegate
            
            def run!
              
              @logger.debug "Forking for build process"
              
              fork do
              
                build_tmp_dir = @job.path.workspace_build_tmp_directory.gsub("\"","\\\"")
                build_dir = @job.path.build_directory.gsub("\"","\\\"")
                src_dir = ::File.join(@job.path.workspace_directory, 'src').gsub("\"","\\\"")
                src_adapter_dir = @job.path.webblocks_src_adapter_directory.gsub("\"","\\\"")
                src_core_dir = @job.path.webblocks_src_core_directory.gsub("\"","\\\"")
                src_extension_dir = @job.path.webblocks_src_extension_directory.gsub("\"","\\\"")
                rakefile_config_file_name = ::File.join(@job.path.workspace_directory, 'Rakefile-config.rb')
                
                Dir.chdir(@job.path.webblocks_directory) do 
                  ::WebBlocks::BuildServer::Support.with_clean_bundler_env do
                    
                    # this should already be initialized so just need to ensure env
                    @logger.info "Initialize bundler"
                    status, stdout, stderr = systemu "bundle"
                    if stderr.length > 0
                      @logger.fatal "Failed to initialize bundler"
                      write_error "Failed to initialize bundler", stdout, stderr
                      exit!
                    end
                    
                    command = "rake -- --config=#{rakefile_config_file_name}"
                    @logger.info "Run build [ #{command} ]"
                    status, stdout, stderr = systemu command
                    if stderr.length > 0
                      @logger.fatal "Build failed"
                      write_error "Build failed", stdout, stderr
                      exit!
                    end
                    @logger.info "Build complete"
                    
                  end
                end
                
                @logger.info "Generating zip of build"
                
                zip_name = @job.path.build_product
                Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) do |zipfile|
                    Dir[File.join(build_dir, '**', '**')].each do |file|
                      zipfile.add(file.sub(build_dir, '').gsub(/^\//,''), file)
                    end
                end
                @logger.info "Generated zip of build -- #{zip_name}"
                
                [@job.path.workspace_metadata, @job.path.build_metadata].each do |metadata_file|
                  File.open metadata_file, 'w' do |f|
                    f.write ::JSON.dump({
                      'status' => ::WebBlocks::BuildServer::Model::Job::MetadataStatus::COMPLETE,
                      'id' => @job.id,
                      'url' => {
                        'download' => @job.app.url("/builds/#{@job.id}/zip"),
                        'browse' => @job.app.url("/builds/#{@job.id}")
                      },
                      'build' => @job.app.params,
                      'server' => @job.app.public_config
                    })
                    @logger.info "Wrote metadata file -- #{metadata_file}"
                  end
                end

              end
              
            end
            
            def write_error msg, out, err
              [@job.path.workspace_metadata, @job.path.build_metadata].each do |metadata_file|
                File.open metadata_file, 'w' do |f|
                  f.write ::JSON.dump({
                    'status' => ::WebBlocks::BuildServer::Model::Job::MetadataStatus::FAILED,
                    'id' => @job.id,
                    'error' => {
                      'message' => msg,
                      'output' => sanitize_message(out),
                      'error' => sanitize_message(err)
                    },
                    'build' => @job.app.params,
                    'server' => @job.app.public_config
                  })
                end
                @logger.info "Wrote metadata file -- #{metadata_file}"
              end
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