require 'extensions/kernel' if defined?(require_relative).nil?
require_relative "../App"
require_relative "Support/Scheduler"
require_relative "Support/SchedulerTask/CleanExpiredBuilds"
require_relative "Support/SchedulerTask/CleanExpiredWorkspaces"
require_relative "Support/SchedulerTask/CleanExpiredIncompleteWorkspaces"

module WebBlocks
  module BuildServer
    class App
      
      @@scheduler = nil
      
      def ensure_scheduler!
        
        if @@scheduler.nil?
          
          @@scheduler = Support::Scheduler.new @config, @logger
          
          if @config['build_expiration'] > 0
            @@scheduler.attach Support::SchedulerTask::CleanExpiredBuilds
          end
          
          if @config['workspace_expiration'] > 0
            @@scheduler.attach Support::SchedulerTask::CleanExpiredWorkspaces
          end
          
          if @config['workspace_incomplete_expiration'] > 0
            @@scheduler.attach Support::SchedulerTask::CleanExpiredIncompleteWorkspaces
          end
          
        end
        @@scheduler.run!
      end
      
      after do
        ensure_scheduler!
      end
      
    end
  end
end




      