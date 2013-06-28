require 'rubygems'
require 'json'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Command
          
          def write_metadata_files metadata_files, metadata
            
            metadata_files.each do |metadata_file|
              File.open metadata_file, 'w' do |f|
                f.write ::JSON.dump(metadata)
              end
            end
            
          end
        end
      end
    end
  end
end