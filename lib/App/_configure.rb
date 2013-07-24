require 'rubygems' if RUBY_VERSION < '1.9'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'json'
require 'multi_json'
require 'fileutils'
require 'git'
require 'systemu'

require_relative "../App"
require_relative '../Support/with_clean_bundler_env'

module WebBlocks
  module BuildServer
    class App
      
      configure :production, :development do
        
        enable :logging
        
        public_config = settings.public_config
        private_config = settings.private_config
        base_dir = ::File.dirname(::File.dirname(::File.dirname(__FILE__)))
        
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
        
        if !config.include?('job_concurrency') || config['job_concurrency'] == 'default'
          if ENV.include?('WEBBLOCKS_BUILD_SERVER_JOB_CONCURRENCY')
            config['job_concurrency'] = ENV['WEBBLOCKS_BUILD_SERVER_JOB_CONCURRENCY']
          else
            config['job_concurrency'] = 'fork'
          end
        end
        
        public_config['job_concurrency'] = config['job_concurrency'] if public_config.include? 'job_concurrency'
        private_config['job_concurrency'] = config['job_concurrency'] if private_config.include? 'job_concurrency'
        
        config['allow'] = {} unless config.include? 'allow'
        ['builds_metadata','builds_raw','builds_zip','jobs_create','jobs_delete','jobs_status'].each do |key|
          config['allow'][key] = false unless config['allow'].include? key
        end
        
        if public_config.include? 'allow'
          public_config['allow'] = config['allow']
        end
        
        private_config['allow'] = config['allow']
        
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
              'npm install',
              '#'
            ]
            
            ignore_error = [
              'npm install'
            ]
            
            startup_commands.each do |startup_command|
              if startup_command != '#'
                puts ">> Initializing WebBlocks -- #{startup_command}"
              else
                puts ">> Build server is ready"
              end
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
      
    end
  end
end

