require 'extensions/kernel' if defined?(require_relative).nil?
require_relative '../Job'

module WebBlocks
  module BuildServer
    module Model
      class Job
        
        module MetadataStatus
          MISSING = 'missing'
          DELETED = 'deleted'
          RUNNING = 'running'
          COMPLETE = 'complete'
          FAILED = 'failed'
        end
        
      end
    end
  end
end