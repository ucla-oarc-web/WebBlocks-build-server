require 'extensions/kernel' if defined?(require_relative).nil?
require_relative '../Route/builds'

module WebBlocks
  module BuildServer
    class App
      
      module Support
      
        module Builds

          def self.with_built_job app, id

            job = Model::Job.new(app, id)

            if job.complete?
              yield job
            elsif job.started?
              app.halt_view 409, "Build \##{id} is not complete."
            else
              app.halt_view 404, "Build \##{id} does not exist."
            end

          end

        end
        
      end
      
    end
  end
end
