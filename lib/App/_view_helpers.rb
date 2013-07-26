require 'extensions/kernel' if defined?(require_relative).nil?
require_relative "../App"

module WebBlocks
  module BuildServer
    class App
      
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
        halt code, erb("layouts/#{layout}".to_sym)
      end
      
    end
  end
end

