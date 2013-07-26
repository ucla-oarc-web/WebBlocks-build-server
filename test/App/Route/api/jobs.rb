require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'json'
require 'multi_json'
require_relative '../../../../lib/Support/Test/RackTestCase'

class TestUnitAppRoute_api_jobs < WebBlocks::BuildServer::Support::Test::RackTestCase
  
  def setup
    
    @job = false
    begin
      sleep 5 if @job
      post 'api/jobs', { 'src-sass-blocks' => "/* #{self.class.name} */" }
      @job = JSON.parse last_response.body
    end while @job['status'] == 'running'
    
  end
  
  def test_api_jobs_200_complete
    
    get "api/jobs/#{@job["id"]}"
    assert last_response.successful?
    metadata = JSON.parse(last_response.body)
    
    ['status','id','build','server','url'].each { |key| assert metadata.include? key }
    ['repository','reference'].each { |key| assert metadata['server'].include? key }
    ['download','browse'].each { |key| assert metadata['url'].include? key }
    
    assert metadata['status'] == 'complete'
    assert metadata['id'] == @job['id']
    
    assert URI.parse(metadata['url']['download']).path == "/builds/#{@job["id"]}/zip"
    assert URI.parse(metadata['url']['browse']).path == "/builds/#{@job["id"]}"
    
  end
  
  def test_api_jobs_200_failed
    
    post 'api/jobs', { 'src-sass-blocks' => "$}" }
    job = JSON.parse(last_response.body)
    
    if job['status'] == 'failed'
      get "api/jobs/#{job["id"]}/delete"
      assert last_response.successful?
      post 'api/jobs', { 'src-sass-blocks' => "$}" }
      job = JSON.parse(last_response.body)
    end
    
    assert last_response.successful?
    assert job['status'] == 'running'
    
    begin # burn out the job
      sleep 5
      get "api/jobs/#{job["id"]}"
      job = JSON.parse last_response.body
    end while job['status'] == 'running'
    
    assert last_response.successful?
    metadata = JSON.parse(last_response.body)
    assert metadata['status'] == 'failed'
    
    ['status','id','error','build','server'].each { |key| assert metadata.include? key }
    ['message','output','error'].each { |key| assert metadata['error'].include? key }
    
  end
  
  def test_api_jobs_503
    
    get "api/jobs/#{@job["id"]}/delete"
    post 'api/jobs', { 'src-sass-blocks' => "/* #{self.class.name} */" }
    sleep 1
    
    post 'api/jobs', { 'src-sass-blocks' => "/* #{self.class.name} - 503 test */" }
    if last_response.successful?
      job = JSON.parse(last_response.body)
      get "api/jobs/#{job["id"]}/delete"
      post 'api/jobs', { 'src-sass-blocks' => "/* #{self.class.name} - 503 test */" }
    end
    
    assert last_response.status == 503
    
    begin # burn out the job
      sleep 5
      get "api/jobs/#{@job["id"]}"
      @job = JSON.parse last_response.body
    end while @job['status'] == 'running'
    
  end
  
  def test_api_jobs_delete_200
    
    get "api/jobs/#{@job["id"]}/delete"
    assert last_response.successful?
    
    # On actual deletion, all settings are returned
    # and only change is status == "deleted"
    
    metadata = JSON.parse(last_response.body)
    
    ['status','id','build','server','url'].each { |key| assert metadata.include? key }
    ['repository','reference'].each { |key| assert metadata['server'].include? key }
    ['download','browse'].each { |key| assert metadata['url'].include? key }
    
    assert metadata['status'] == "deleted"
    assert metadata['id'] == @job['id']
    
    assert URI.parse(metadata['url']['download']).path == "/builds/#{@job["id"]}/zip"
    assert URI.parse(metadata['url']['browse']).path == "/builds/#{@job["id"]}"
    
    # Subsequent calls should return 404
    
    get "api/jobs/#{@job["id"]}/delete"
    assert last_response.not_found?
    assert last_response.body == "Cannot delete. Build \##{@job["id"]} does not exist."
    
  end
  
  def test_api_jobs_delete_404
    
    get "api/jobs/#{@job["id"]}/delete"
    assert last_response.successful?
    [@job["id"], "missing"].each do |id|
      get "api/jobs/#{id}/delete"
      assert last_response.not_found?
      assert last_response.body == "Cannot delete. Build \##{id} does not exist."
    end
    
  end
  
  def test_api_jobs_delete_409
    
    get "api/jobs/#{@job["id"]}/delete"
    post 'api/jobs', { 'src-sass-blocks' => "/* #{self.class.name} */" }
    job = JSON.parse last_response.body
    get "api/jobs/#{job["id"]}/delete"
    puts last_response.status
    assert last_response.status == 409
    
    begin # burn out the job
      sleep 5
      get "api/jobs/#{job["id"]}"
      job = JSON.parse last_response.body
    end while job['status'] == 'running'
    
  end
  
end