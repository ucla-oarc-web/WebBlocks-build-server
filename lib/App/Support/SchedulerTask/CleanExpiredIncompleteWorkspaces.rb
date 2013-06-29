require 'fileutils'

module WebBlocks
  module BuildServer
    class App
      module Support
        module SchedulerTask
      
          class CleanExpiredIncompleteWorkspaces

            def initialize scheduler
              
              @config = scheduler.config
              @logger = scheduler.logger.class.new(STDOUT)
              @logger.progname = "#{scheduler.logger.progname} -- TASK CleanExpiredIncompleteWorkspaces"
              
              @build_path = nil
              @workspace_path = nil
              
              file_root = File.dirname File.dirname File.dirname File.dirname File.dirname __FILE__
              
              Dir.chdir file_root do
                Dir.chdir "#{@config['workspace_dir']}/#{@config['reference']}" do
                  @workspace_path = Dir.pwd
                end
                Dir.chdir "#{@config['build_dir']}/#{@config['reference']}" do
                  @build_path = Dir.pwd
                end
              end
              
            end

            def run!
              
              @logger.debug "Start"
              
              Dir.foreach @workspace_path do |file|
                
                next if file[0,1] == '.' or file[0,1] == '_'
                
                workspace_file = "#{@workspace_path}/#{file}"
                build_file = "#{@build_path}/WebBlocks.#{file}.json"
                
                next if File.exists? build_file
                
                if File.mtime("#{workspace_file}/metadata.json") < (Time.now - (@config['workspace_incomplete_expiration']))
                  FileUtils.rm_rf workspace_file
                  @logger.debug "Expired incomplete workspace \##{file} -- Deleted #{workspace_file}"
                end
                
              end
              
              @logger.debug "Done"
              
            end
            
          end

        end
      end
    end
  end
end
