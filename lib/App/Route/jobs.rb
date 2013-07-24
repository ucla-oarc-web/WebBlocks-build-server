require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?

require_relative "../../Model/Job"
require_relative "../../App"

module WebBlocks
  module BuildServer
    class App
      
      get '/jobs/create' do
        
        if @config['allow']['jobs_create']
        
        @action = '/api/jobs'
        @method = 'POST'
        view 'jobs/create'
        
        else
        
          halt_view 403, "Jobs creation support not available."
          
        end
        
      end
      
    end
  end
end

