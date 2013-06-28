require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?

require 'sinatra'
require 'sinatra/json'
require 'sinatra/config_file'
require 'json'
require 'multi_json'
require 'fileutils'
require 'git'
require 'systemu'

require_relative 'Support/with_clean_bundler_env'

module WebBlocks
  module BuildServer
    class App < Sinatra::Base
      
      register Sinatra::ConfigFile
      helpers Sinatra::JSON
      
      config_file ::File.join( ::File.dirname(::File.dirname(__FILE__)), "settings.yml" )
      
      configure :production, :development do
        
        enable :logging
        
        public_config = settings.public_config
        private_config = settings.private_config
        base_dir = ::File.dirname(::File.dirname(__FILE__))
        
        if public_config.include? 'workspace_dir'
          public_config['workspace_dir'] = ::File.join( base_dir, public_config['workspace_dir'] ) 
        end
        
        if private_config.include? 'workspace_dir'
          private_config['workspace_dir'] = ::File.join( base_dir, private_config['workspace_dir'] ) 
        end
        
        if public_config.include? 'build_dir'
          public_config['build_dir'] = ::File.join( base_dir, public_config['build_dir'] ) 
        end
        
        if private_config.include? 'build_dir'
          private_config['build_dir'] = ::File.join( base_dir, private_config['build_dir'] ) 
        end
        
        config = public_config.merge(private_config)
        
        set :public_config, public_config
        set :private_config, private_config
        set :config, config
        
        build_dir = ::File.join( config['build_dir'], "#{config['reference']}" )
        puts ">> Setting up build directory #{build_dir}"
        FileUtils.mkdir_p build_dir
              
        webblocks_dir = ::File.join( config['workspace_dir'], "#{config['reference']}", '_WebBlocks' )
        
        puts ">> Setting up workspace #{File.dirname webblocks_dir}"
        FileUtils.mkdir_p File.dirname webblocks_dir
        
        unless File.exists? webblocks_dir
          puts ">> Initializing WebBlocks -- git clone #{config['repository']} #{webblocks_dir} "
          repo = Git.clone config['repository'], '_WebBlocks', { :path => File.dirname(webblocks_dir) }
          puts ">> Initializing WebBlocks -- git branch -b deploy #{config['reference']} "
          repo.checkout config['reference'], { :new_branch => "deploy" }
        else
          #
          # might do something like this later if we get better cache sense...
          #
          #   repo = Git.open webblocks_dir
          #   repo.pull repo.remotes.first, config['reference']
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
      attr_accessor :config
      attr_accessor :logger
      
      before do
        
        @public_config = settings.public_config
        @config = settings.config
        @logger = Logger.new(STDOUT)
        
      end
      
      def view file, layout = "main"
        @body_content = erb file.to_sym
        erb "layouts/#{layout}".to_sym
      end
      
      def raw_view text, layout = "main"
        @body_content = text
        erb "layouts/#{layout}".to_sym
      end
      
      def halt_view code, text, layout = "main"
        @body_content = "<h3>#{code} Error</h3><p>#{text}</p>"
        erb "layouts/#{layout}".to_sym
      end
      
    end
  end
end

# Routes

require_relative "App/api/config"
require_relative "App/api/jobs"
require_relative "App/builds"
require_relative "App/jobs"

