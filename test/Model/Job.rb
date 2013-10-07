require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'fileutils'
require_relative '../../lib/Support/Test/RackTestCase'

class TestUnitModelJob < WebBlocks::BuildServer::Support::Test::RackTestCase
  
  def setup
    
    app.attach_instance_variables!
    @id = 'identifier'
    @job = ::WebBlocks::BuildServer::Model::Job.new app, @id
    
  end
  
  def test_accessors
    
    assert @job.respond_to? 'id'
    assert @job.respond_to? 'path'
    assert @job.respond_to? 'app'
    assert @job.respond_to? 'logger'
    
    assert @job.id == @id
    assert @job.path.is_a? ::WebBlocks::BuildServer::Model::Job::Path
    assert @job.app === app
    assert @job.logger.is_a? Logger
    assert @job.logger.progname == "JOB \##{@id}"
    
  end
  
  def test_path
    
    reference = @job.app.config['reference']
    root_path = File.dirname File.dirname File.dirname __FILE__
    
    assert @job.path.build_directory == "#{root_path}/test/tmp/build/#{reference}/#{@id}"
    assert @job.path.build_product == "#{root_path}/test/tmp/build/#{reference}/WebBlocks.#{@id}.zip"
    assert @job.path.build_metadata == "#{root_path}/test/tmp/build/#{reference}/WebBlocks.#{@id}.json"
    assert @job.path.workspace_directory == "#{root_path}/test/tmp/workspace/#{reference}/#{@id}"
    assert @job.path.workspace_build_tmp_directory == "#{root_path}/test/tmp/workspace/#{reference}/#{@id}/.build-tmp"
    assert @job.path.workspace_metadata == "#{root_path}/test/tmp/workspace/#{reference}/#{@id}/metadata.json"
    
  end
  
  def test_refresh!
    
    FileUtils.rm_f @job.path.workspace_metadata
    FileUtils.rm_f @job.path.build_metadata
    
    @job.refresh!
    
    assert @job.instance_variable_get(:@workspace_metadata) == nil
    assert @job.instance_variable_get(:@build_metadata) == nil
    
    FileUtils.mkdir_p File.dirname @job.path.workspace_metadata
    File.open(@job.path.workspace_metadata, 'w') { |f| f.write ::JSON.dump({ 'key' => 'val' }) }
    
    @job.refresh!
    
    assert @job.instance_variable_get(:@workspace_metadata)['key'] == 'val'
    assert @job.instance_variable_get(:@build_metadata) == nil
    
    FileUtils.rm_f @job.path.workspace_metadata
    FileUtils.mkdir_p File.dirname @job.path.build_metadata
    File.open(@job.path.build_metadata, 'w') { |f| f.write ::JSON.dump({ 'key' => 'val' }) }
    
    @job.refresh!
    
    assert @job.instance_variable_get(:@workspace_metadata) == nil
    assert @job.instance_variable_get(:@build_metadata)['key'] == 'val'
    
  end
  
end