module WebBlocks
  module BuildServer
    module Support
      BUNDLER_VARS = %w(BUNDLE_GEMFILE RUBYOPT BUNDLE_BIN_PATH)
      def self.with_clean_bundler_env
        bundled_env = ENV.to_hash
        BUNDLER_VARS.each{ |var| ENV.delete(var) }
        yield
      ensure
        ENV.replace(bundled_env.to_hash)
      end
    end
  end
end