require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?

require_relative "../../../Model/Job"
require_relative "../../../App"
require_relative '../../../Support/Error/ResourceError'

module WebBlocks
  module BuildServer
    class App
      
      post '/api/jobs' do
        
        if @config['allow']['jobs_create']
        
          begin
            json Model::Job.create(self, params).metadata
          rescue ::WebBlocks::BuildServer::Support::Error::ResourceError => error
            halt 503, error.message
          end
          
        else
          
          halt 403, "Jobs create support not available."
          
        end
        
      end
      
      get '/api/jobs/:id/delete' do |id|
        
        if @config['allow']['jobs_delete']
        
          job = Model::Job.new(self, id)

          if job.complete?
            job.destroy!
            json job.metadata 
          elsif job.started?
            halt 409, "Cannot delete. Build \##{id} is currently in progress."
          else
            halt 404, "Cannot delete. Build \##{id} does not exist."
          end
          
        else
          
          halt 403, "Jobs delete support not available."
          
        end
        
      end
      
      get '/api/jobs/:id' do |id|
        
        if @config['allow']['jobs_status']
        
          json Model::Job.new(self, id).metadata
          
        else
          
          halt 403, "Jobs status support not available."
          
        end
        
      end
      
    end
  end
end

