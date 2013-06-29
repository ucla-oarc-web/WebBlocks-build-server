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
      
      config_file ::File.join( ::File.dirname(::File.dirname(__FILE__)), "settings.yml" )
      
    end
  end
end

[
  # Bootstrap
  '_configure',
  '_instance_variables',
  '_resource_pool',
  '_view_helpers',
  
  # Routes
  'api/config',
  'api/jobs',
  'builds',
  'jobs'

].each do |file|
  require_relative "App/#{file}"
end