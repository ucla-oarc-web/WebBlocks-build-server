require 'rubygems'
require 'zip/zip'

module WebBlocks
  module BuildServer
    module Support
      module Job
        module Command
          
          def zip_directory zip_file_path, directory_to_zip
            
            Zip::ZipFile.open(zip_file_path, Zip::ZipFile::CREATE) do |zipfile|
              Dir[File.join(directory_to_zip, '**', '**')].each do |file|
                zipfile.add(file.sub(directory_to_zip, '').gsub(/^\//,''), file)
              end
            end
            
          end
        end
      end
    end
  end
end