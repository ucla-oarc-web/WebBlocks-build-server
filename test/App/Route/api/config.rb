require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'json'
require 'multi_json'
require_relative '../../../../lib/Support/Test/RackTestCase'

class TestUnitAppRoute_api_config < WebBlocks::BuildServer::Support::Test::RackTestCase
  
  def test_api_config_200
    
    get "api/config"
    assert last_response.successful?
    config = JSON.parse(last_response.body)
    ['repository','reference'].each { |key| assert config.include? key }
    
  end
  
end