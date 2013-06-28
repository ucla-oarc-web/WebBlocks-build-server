require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?

require_relative "../../App"

module WebBlocks
  module BuildServer
    class App
      
      get '/api/config' do
        json @public_config
      end
      
    end
  end
end

