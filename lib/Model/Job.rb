require 'extensions/kernel' if defined?(require_relative).nil?
require 'json'
require_relative '../Support/Model'
require_relative '../Support/Job/StrategyFactory'

module WebBlocks
  module BuildServer
    module Model
      class Job < ::WebBlocks::BuildServer::Support::Model
        
        attr_accessor :id, :path
        
        def initialize app, id
          
          @id = id
          
          super app, "JOB \##{@id}"
          
          @path = Path.new self
          
          @workspace_metadata = File.exists?(@path.workspace_metadata) ? 
            JSON.parse(File.read @path.workspace_metadata) : nil
          
          @build_metadata = File.exists?(@path.build_metadata) ?
            JSON.parse(File.read @path.build_metadata) : nil
          
          
        end
        
        def self.create app, params
          
          id = Digest::MD5.hexdigest(params.to_s)
          job = Job.new(app, id)
          
          unless job.started?
            ::WebBlocks::BuildServer::Support::Job::StrategyFactory.new(job).build_each do |strategy|
              strategy.run!
            end
            job.refresh!
          end
          
          job
          
        end
        
        def refresh!
          
          @workspace_metadata = File.exists?(@path.workspace_metadata) ? 
            JSON.parse(File.read @path.workspace_metadata) : nil
          
          @build_metadata = File.exists?(@path.build_metadata) ?
            JSON.parse(File.read @path.build_metadata) : nil
          
        end
        
        def delete!
          job_artifacts.each { |artifact| FileUtils.rm_rf artifact }
          @workspace_metadata['status'] = MetadataStatus::DELETED if @workspace_metadata
        end
        
        def destroy!
          delete!
          build_artifacts.each { |artifact| FileUtils.rm_rf artifact }
          @build_metadata['status'] = MetadataStatus::DELETED if @build_metadata
        end
        
        def metadata
          metadata = @build_metadata ? @build_metadata : @workspace_metadata
          metadata ? metadata : {'id'=>@id, 'status'=>MetadataStatus::MISSING}
        end
        
        def started?
          metadata['status'] != MetadataStatus::MISSING
        end
        
        def running?
          metadata['status'] == MetadataStatus::RUNNING
        end
        
        def complete?
          metadata['status'] == MetadataStatus::COMPLETE or failed?
        end
        
        def failed?
          metadata['status'] == MetadataStatus::FAILED
        end
        
        def missing?
          !started?
        end
        
        def completely_missing?
          missing? and (job_artifacts | build_artifacts).none { |artifact| File.exists? artifact }
        end
        
        def job_artifacts
          [
            @path.workspace_directory
          ]
        end
        
        def build_artifacts
          [
            @path.build_directory,
            @path.build_product,
            @path.build_metadata
          ]
        end
        
        def to_hash
          {
            'metadata' => metadata,
            'path' => @path.to_hash,
            'app' => @app.config
          }
        end
        
      end
    end
  end
end

require_relative 'Job/MetadataStatus.rb'
require_relative 'Job/Path.rb'