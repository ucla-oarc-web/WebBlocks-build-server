require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?

require_relative "../../Model/Job"
require_relative "../../App"
require_relative '../../Support/Error/ResourceError'

module WebBlocks
  module BuildServer
    class App
      
      post '/api/jobs' do
        
        begin
          json Model::Job.create(self, params).metadata
        rescue ::WebBlocks::BuildServer::Support::Error::ResourceError => error
          halt 503, error.message
        end
        
      end
      
      get '/api/jobs/:id/delete' do |id|
        
        job = Model::Job.new(self, id)
        
        if job.complete?
          job.destroy!
          json job.metadata 
        elsif job.started?
          halt 409, "Cannot delete. Build \##{id} is currently in progress."
        else
          halt 404, "Cannot delete. Build \##{id} does not exist."
        end
        
      end
      
      get '/api/jobs/:id' do |id|
        
        json Model::Job.new(self, id).metadata
        
      end
      
    end
  end
end

