module WebBlocks
  module BuildServer
    class App
      module Support
        module SchedulerTask
      
          class CleanExpiredBuilds

            def initialize scheduler
              
              @config = scheduler.config
              @logger = scheduler.logger.class.new(STDOUT)
              @logger.progname = "#{scheduler.logger.progname} -- TASK CleanExpiredBuilds"
              
              @build_path = nil
              @workspace_path = nil
              
              file_root = File.dirname File.dirname File.dirname File.dirname File.dirname __FILE__
              
              Dir.chdir file_root do
                Dir.chdir "#{@config['build_dir']}/#{@config['reference']}" do
                  @build_path = Dir.pwd
                end
                Dir.chdir "#{@config['workspace_dir']}/#{@config['reference']}" do
                  @workspace_path = Dir.pwd
                end
              end
              
            end

            def run!
              
              @logger.debug "Start"
              
              Dir.chdir @build_path do
                Dir.glob('WebBlocks.[A-Za-z0-9]*.json').each do |file|
                  
                  next unless File.mtime(file) < (Time.now - (@config['build_expiration']))
                  
                  id = file.gsub(/^WebBlocks\./,'').gsub(/\.json$/, '')
                  FileUtils.rm_rf "#{id}"
                  @logger.debug "Expired build \##{id} -- Deleted #{@build_path}/#{id}/"
                  FileUtils.rm_f "WebBlocks.#{id}.zip"
                  @logger.debug "Expired build \##{id} -- Deleted #{@build_path}/WebBlocks.#{id}.zip"
                  FileUtils.rm_f file
                  @logger.debug "Expired build  \##{id} -- Deleted #{@build_path}/#{file}"
                  
                  if File.exists? "#{@workspace_path}/#{id}"
                    FileUtils.rm_rf "#{@workspace_path}/#{id}"
                    @logger.debug "Expired build \##{id} -- Deleted #{@workspace_path}/#{id}"
                  end
                  
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
