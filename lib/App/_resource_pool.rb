require 'extensions/kernel' if defined?(require_relative).nil?
require_relative "../App"

module WebBlocks
  module BuildServer
    class App
      
      @@resource_pool_child_pids = []
      
      def refresh_resource_pool_child_pids!
        
        @@resource_pool_child_pids = @@resource_pool_child_pids.select do |pid|
          begin
            Process.getpgid( pid )
            true
          rescue Errno::ESRCH
            false
          end
        end
        @@resource_pool_child_pids
        
      end
      
      def resource_pool_child_pids
        
        refresh_resource_pool_child_pids!
        
      end
      
      def add_resource_pool_child_pid pid
        
        @@resource_pool_child_pids << pid
        
      end
      
      def has_resources?
        
        if !@config.include?('resource_pool')
          true
        elsif !@config['resource_pool'].include?('child_processes') or @config['resource_pool']['child_processes'].nil?
          true
        elsif @config['resource_pool']['child_processes'] < 0
          true
        elsif resource_pool_child_pids.size < @config['resource_pool']['child_processes']
          true
        else
          false
        end
        
      end
      
    end
  end
end




      