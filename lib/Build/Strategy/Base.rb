require ::File.join( ::File.dirname(__FILE__), "Base" )

module WebBlocks
  module BuildServer
    module Build
      module Strategy
        class Base
          def initialize job
            @job = job
          end
        end
      end
    end
  end
end