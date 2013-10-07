require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?

require 'sinatra'
require 'sinatra/json'
require 'sinatra/config_file'

module WebBlocks
  module BuildServer
    class App < Sinatra::Base
      
      register Sinatra::ConfigFile
      helpers Sinatra::JSON
      
      settings_path = ::File.join( ::File.dirname(::File.dirname(__FILE__)), "settings.yml" )
      if ENV.include? "WEBBLOCKS_BUILD_SERVER_ENV" and ENV["WEBBLOCKS_BUILD_SERVER_ENV"] == 'test'
        settings_path = ::File.join( ::File.dirname(::File.dirname(__FILE__)), "test/settings.yml" )
      end
      config_file settings_path
      
    end
  end
end

[
  # Bootstrap
  '_configure',
  '_instance_variables',
  '_resource_pool',
  '_scheduler',
  '_view_helpers',
  
  # Routes
  'Route/api/config',
  'Route/api/jobs',
  'Route/builds',
  'Route/jobs'

].each do |file|
  require_relative "App/#{file}"
end
