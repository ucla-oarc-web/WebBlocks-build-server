require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'resque/tasks'
require 'fileutils'


Rake::TestTask.new do |t|
  ENV["WEBBLOCKS_BUILD_SERVER_ENV"] = ENV["WEBBLOCKS_BUILD_SERVER_ENV"] || "test"
  t.test_files = FileList['test/App/**/*.rb']
end

namespace :test do
  
  namespace :app do
    Rake::TestTask.new :routes do |t|
      ENV["WEBBLOCKS_BUILD_SERVER_ENV"] = ENV["WEBBLOCKS_BUILD_SERVER_ENV"] || "test"
      t.pattern = 'test/App/Route/**/*.rb'
    end
  end
  
  task :clean do
    ['build', 'workspace'].each do |dir|
      Dir.glob("test/tmp/#{dir}/*/*") do |item|
        basename = File.basename item
        next if basename[0,1] == '.' or basename[0,1] == '_'
        FileUtils.rm_rf item
      end
    end
  end
  
end

namespace :resque do
  task :setup do
    puts "*** Loading WebBlocks Build Server environment for Resque"
    require 'extensions/kernel' if defined?(require_relative).nil?
    require_relative 'lib/Support/Job/Delegate/ExecuteBuild/Resque'
  end
end
