require 'lita'
require 'dotenv'
require 'active_support'
require 'active_support/core_ext/module/aliasing'

module Lita
  class << self
    def env
      @env ||= ActiveSupport::StringInquirer.new(ENV['LITA_ENV'] || 'development')
    end

    def root
      @root ||= ENV['LITA_ROOT'] ||= File.expand_path('.')
    end
  end

  module Ext
    class Core
		
      class << self
        def call(payload)
          chdir_to_lita_root
          load_dotenv
          add_lib_to_load_path
					load_environment_config
					load_initializers
					load_models
					load_app_handlers
					register_app_handlers
				end

        private

        def chdir_to_lita_root
          Dir.chdir(Lita.root)
        end

				def load_models
					models = "#{Lita.root}/app/models/**/*.rb"
          Dir.glob(models).each { |model| require model }
				end
				
        def load_dotenv
          Dotenv.load ".env.#{Lita.env}", '.env'
        end

        def add_lib_to_load_path
          lib = File.expand_path('lib', Lita.root)
          $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
        end

        def load_initializers
          initializers = "#{Lita.root}/config/initializers/**/*.rb"
          Dir.glob(initializers).each { |initializer| require initializer }
        end

        def load_app_handlers
          handlers = "#{Lita.root}/app/handlers/**/*.rb"
          Dir.glob(handlers).each { |handler| require handler }
        end

        def register_app_handlers
          Lita::Handler.handlers.each do |handler|
						Lita.register_handler(handler) unless handler.disabled?
          end
        end

        def load_environment_config
          environment = "#{Lita.root}/config/environments/#{Lita.env}"
          if File.exists?("#{environment}.rb")
            require environment
          end
        end
      end
    end

    Lita.register_hook(:before_run, Core)
  end
end
