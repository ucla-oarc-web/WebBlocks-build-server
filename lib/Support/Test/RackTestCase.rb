require 'rubygems'
require 'extensions/kernel' if defined?(require_relative).nil?
require 'rack/test'
require 'hpricot'
require_relative 'TestCase'

APP = Rack::Builder.parse_file('config.ru').first

module WebBlocks
  module BuildServer
    module Support
      module Test
        class RackTestCase < TestCase
  
          include Rack::Test::Methods

          def app
            APP.helpers
          end
  
          def assert_last_response_body_html_has_link_with_path url, msg = ''
            doc = Hpricot(last_response.body)
            assert (doc/"a").select { |a|  URI.parse(a.attributes['href']).path == url }.length > 0, msg
          end
          
        end
      end
    end
  end
end