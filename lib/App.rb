require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?

require 'sinatra'
require 'sinatra/json'
require 'json'
require 'multi_json'
require 'fileutils'
require 'git'
require 'systemu'

require_relative 'Build/Job'
require_relative 'Flush/Job'
require_relative 'Status/Job'
require_relative 'Support/with_clean_bundler_env'

module WebBlocks
  module BuildServer
    class App < Sinatra::Base
      
      # Application Setup
      
      helpers Sinatra::JSON
      
      configure :production, :development do
        
        enable :logging
        
        @public_config = {
          'repository' => 'https://github.com/ucla/WebBlocks.git',
          'reference' => 'v1.0.08'  # MUT be commit ID or tag, NOT branch name
        }
        
        @private_config = {
          'workspace_dir' => ::File.join( ::File.dirname(::File.dirname(__FILE__)), "workspace" ),
          'build_dir' => ::File.join( ::File.dirname(::File.dirname(__FILE__)), "build" ),
          'threads' => 4
        }
        
        @config = @public_config.merge(@private_config)
        
        set :public_config, @public_config
        set :config, @config
        
        build_dir = ::File.join( @config['build_dir'], "#{@config['reference']}" )
        puts ">> Setting up build directory #{build_dir}"
        FileUtils.mkdir_p build_dir
              
        webblocks_dir = ::File.join( @config['workspace_dir'], "#{@config['reference']}", '_WebBlocks' )
        
        puts ">> Setting up workspace #{File.dirname webblocks_dir}"
        FileUtils.mkdir_p File.dirname webblocks_dir
        
        unless File.exists? webblocks_dir
          puts ">> Initializing WebBlocks -- git clone #{@config['repository']} #{webblocks_dir} "
          repo = Git.clone @config['repository'], '_WebBlocks', { :path => File.dirname(webblocks_dir) }
          puts ">> Initializing WebBlocks -- git branch -b deploy #{@config['reference']} "
          repo.checkout @config['reference'], { :new_branch => "deploy" }
        else
          #
          # might do something like this later if we get better cache sense...
          #
          #   repo = Git.open webblocks_dir
          #   repo.pull repo.remotes.first, @config['reference']
          #
        end
        
        Support.with_clean_bundler_env do
          Dir.chdir webblocks_dir do
            
            startup_commands = [
              'git submodule init',
              'git submodule update',
              'bundle',
              'npm install'
            ]
            
            ignore_error = [
              'npm install'
            ]
            
            startup_commands.each do |startup_command|
              puts ">> Initializing WebBlocks -- #{startup_command}"
              status, stdout, stderr = systemu startup_command
              if stderr.length > 0
                unless ignore_error.include?(startup_command)
                  puts "Crash during WebBlocks workspace initialiation for command:"
                  puts "\n    #{startup_command}"
                  puts "Error returned was:"
                  puts "\n    #{stderr}"
                  exit! 1
                end
              end
            end
            
          end
        end
        
      end
      
      attr_accessor :public_config
      
      before do
        
        @public_config = settings.public_config
        @config = settings.config
        @logger = Logger.new(STDOUT)
        
      end
      
      def view file, layout = "main"
        @body_content = erb file.to_sym
        erb "layouts/#{layout}".to_sym
      end
      
      def run job
        result = job.run!
        job.end!
        result
      end
      
      # Application Routes
      
      get '/config' do
        json @public_config
      end
      
      get '/jobs/create' do
        @action = '/jobs'
        @method = 'POST'
        view 'jobs/create'
      end
      
      post '/jobs' do
        json run Build::Job.new self, params, @config, @logger
      end
      
      get '/jobs/:id/flush' do |id|
        json run Flush::Job.new self, id, @config, @logger
      end
      
      get '/jobs/:id' do |id|
        json run Status::Job.new self, id, @config, @logger
      end
      
    end
  end
end

