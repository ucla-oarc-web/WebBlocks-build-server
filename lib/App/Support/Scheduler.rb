require 'extensions/kernel' if defined?(require_relative).nil?
require_relative '../../App'

module WebBlocks
  module BuildServer
    class App
      
      module Support
      
        class Scheduler
          
          @@pid = nil
          
          attr_accessor :config, :logger
          
          def initialize config, logger
            @config = config
            @logger = logger.class.new(STDOUT)
            @logger.progname = "SCHEDULER"
            @tasks = []
          end
          
          def running?
            if @@pid
              begin
                Process.getpgid( @@pid )
                true
              rescue Errno::ESRCH
                @@pid = nil
                false
              end
            else
              false
            end
          end
          
          def attach task
            @tasks << task.new(self)
          end
          
          def run!
            unless running?
              if @config['cleanup_frequency'] > 0
                pid = fork do
                  trap("INT") { exit }
                  trap("EXIT") { exit }
                  trap("QUIT") { exit }
                  while true
                    sleep @config['cleanup_frequency']
                    @tasks.each do |task|
                      task.run!
                    end
                  end
                end
                @@pid = pid if pid
              end
            end
          end

        end
        
      end
      
    end
  end
end
