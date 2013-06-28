module WebBlocks
  module BuildServer
    module Support
      module Job
        module Command
          class CommandError < ::RuntimeError

            attr_accessor :output, :error

            def initialize message = nil, output = nil, error = nil
              super message
              @output = output
              @error = error
            end

            def to_hash
              {
                'message' => message,
                'output' => output,
                'error' => error
              }
            end

          end
        end
      end
    end
  end
end