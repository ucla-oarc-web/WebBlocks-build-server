require 'extensions/kernel' if defined?(require_relative).nil?
require_relative 'Base'

module WebBlocks
  module BuildServer
    module Build
      module Strategy
        class RakefileConfig < Base

          def run! json_data
            
            data = JSON.load(json_data)
            
            supported_vars = [
              ['build','debug'],
              ['build','packages'],
              ['package','bootstrap','scripts'],
              ['src','adapter'],
              ['src','extensions'],
              ['src','modules'],
            ]
            
            lines = []
            supported_vars.each do |supported_var|
              line = generate_variable_line data, supported_var
              lines << line if line
            end
            
            file_name = ::File.join(@job.workspace_directory, 'Rakefile-config.rb')
            File.open file_name, 'w' do |f| 
              f.write lines.join "\n"
            end
            @job.logger.info "Saved #{file_name}"
            
          end
          
          def generate_variable_line data, args
            
            queue = args.clone
            data = data.clone
            
            until queue.empty?
              property = queue.shift
              return false unless data[property]
              data = data[property]
            end
            
            "#{generate_variable_name args}  = #{generate_variable_value data};"
            
          end
          
          def generate_variable_name names
            
            arr = []
            names.each do |name|
              arr.push "[:#{name.gsub /[^0-9a-z_]/i, ''}]"
            end
            
            "WebBlocks.config#{arr.join}"
            
          end
          
          def generate_variable_value value
            
            if value.is_a? Hash
              
              values = []
              value.each do |subkey, subvalue|
                values << "\"#{subkey.gsub /[^0-9a-z_\- ]/i, ''}\" => #{generate_variable_value subvalue}"
              end
              
              "{#{values.join(',')}}"
              
            elsif value.is_a? Array
              
              values = []
              value.each do |subvalue|
                values << generate_variable_value(subvalue)
              end
              
              "[#{values.join(',')}]";
              
            elsif value.is_a? Numeric
              
              value
              
            elsif value.is_a? FalseClass or value == "false"
              
              "false"
              
            elsif value.is_a? TrueClass or value == "true"
              
              "true"
              
            else
              
              "\"#{value.gsub /[^0-9a-z_\- ]/i, ''}\""
              
            end
            
          end

        end
      end
    end
  end
end