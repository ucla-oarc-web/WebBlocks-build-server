require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?

require_relative "../../Model/Job"
require_relative "../../App"

module WebBlocks
  module BuildServer
    class App
      
      post '/api/jobs' do
        
        json Model::Job.create(self, params).metadata
        
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

