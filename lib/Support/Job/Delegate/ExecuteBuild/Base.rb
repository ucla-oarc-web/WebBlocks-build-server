require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'json'
require_relative '../Delegate'
require_relative '../../Command/write_metadata_files'
require_relative '../../../../Model/Job.rb'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Delegate
          module ExecuteBuild
            class Base < ::WebBlocks::BuildServer::Support::Job::Delegate::Delegate
              
              def initialize job
                
                super job
                
                @build_dir = @job.path.build_directory.gsub("\"","\\\"")
                @build_product = @job.path.build_product
                @webblocks_dir = @job.path.webblocks_directory
                @rakefile_config_file_name = ::File.join(@job.path.workspace_directory, 'Rakefile-config.rb')

                @metadata_files = [@job.path.workspace_metadata, @job.path.build_metadata]
                @metadata = @job.metadata

                @complete_metadata = @metadata.merge({
                  'status' => ::WebBlocks::BuildServer::Model::Job::MetadataStatus::COMPLETE,
                  'url' => {
                    'download' => @job.app.url("/builds/#{@job.id}/zip"),
                    'browse' => @job.app.url("/builds/#{@job.id}")
                  }
                })

                @failed_metadata = @metadata.merge({
                  'status' => ::WebBlocks::BuildServer::Model::Job::MetadataStatus::FAILED,
                  'error' => {
                    'message' => 'Error encountered',
                    'output' => '',
                    'error' => ''
                  }
                })
                
              end
              
              def to_hash
                {
                  'build_dir' => @build_dir,
                  'build_product' => @build_product,
                  'webblocks_dir' => @webblocks_dir,
                  'rakefile_config_file_name' => @rakefile_config_file_name,
                  'metadata_files' => @metadata_files,
                  'metadata' => @metadata,
                  'complete_metadata' => @complete_metadata,
                  'failed_metadata' => @failed_metadata
                }
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