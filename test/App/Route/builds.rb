require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'json'
require 'multi_json'
require 'uri'
require 'zip/zip'
require_relative '../../../lib/Support/Test/RackTestCase'

class TestUnitAppRoute_builds < WebBlocks::BuildServer::Support::Test::RackTestCase
  
  def setup
    
    @job = false
    begin
      sleep 5 if @job
      post 'api/jobs', { 'src-sass-blocks' => "/* #{self.class.name} */" }
      @job = JSON.parse last_response.body
    end while @job['status'] == 'running'
    
  end
  
  def test_builds_200
    
    get "builds/#{@job["id"]}"
    assert last_response.successful?
    
    [
      "/builds/#{@job["id"]}/zip",
      "/builds/#{@job["id"]}/raw/css/blocks.css",
      "/builds/#{@job["id"]}/raw/css/blocks-ie.css",
      "/builds/#{@job["id"]}/raw/js/blocks.js",
      "/builds/#{@job["id"]}/raw/js/blocks-ie.js"
    ].each do |path|
      assert_last_response_body_html_has_link_with_path path
    end
    
  end
  
  def test_builds_metadata_200
    
    get "builds/#{@job["id"]}/metadata"
    assert last_response.successful?
    metadata = JSON.parse(last_response.body)
    
    ['status','id','build','server','url'].each { |key| assert metadata.include? key }
    ['repository','reference'].each { |key| assert metadata['server'].include? key }
    ['download','browse'].each { |key| assert metadata['url'].include? key }
    
    assert metadata['status'] == @job['status']
    assert metadata['id'] == @job['id']
    
    assert URI.parse(metadata['url']['download']).path == "/builds/#{@job["id"]}/zip"
    assert URI.parse(metadata['url']['browse']).path == "/builds/#{@job["id"]}"
    
  end
  
  def test_builds_raw_200
    
    ['css/blocks.css','css/blocks-ie.css','js/blocks.js','js/blocks-ie.js'].each do |path|
      get "builds/#{@job["id"]}/raw/#{path}"
      assert last_response.successful?
    end
    
  end
  
  def test_builds_zip_200
    
    get "builds/#{@job["id"]}/zip"
    assert last_response.successful?
    
    tmp_file = "#{File.dirname File.dirname File.dirname __FILE__}/tmp/test.zip"
    File.write tmp_file, last_response.body
    Zip::ZipFile.open(tmp_file) do |zipfile|
      ['css/blocks.css','css/blocks-ie.css','js/blocks.js','js/blocks-ie.js'].each do |path|
        assert zipfile.select { |entry| entry.name == path }.length > 0, "#{path} must exist in zip"
      end
    end
    File.delete tmp_file
    
  end
  
  def test_builds_404
    
    get "builds/missing"
    assert last_response.not_found?
    
  end
  
  def test_builds_metadata_404
    
    get "builds/missing/metadata"
    assert last_response.not_found?
    
  end
  
  def test_builds_raw_404
    
    ['css/blocks.css','css/blocks-ie.css','js/blocks.js','js/blocks-ie.js'].each do |path|
      get "builds/missing/raw/#{path}"
      assert last_response.not_found?
    end
    
    get "builds/#{@job["id"]}/raw/missing"
    assert last_response.not_found?
    
  end
  
  def test_builds_zip_404
    
    get "builds/missing/zip"
    assert last_response.not_found?
    
  end
  
end