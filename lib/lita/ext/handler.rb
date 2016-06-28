require 'lita'
require 'lita/handler'

module Lita
  class Handler
		config :disabled, required: false, default: false
		
    def config_valid?
      valid = true
      self.class.config_options.each do |config_option|
        if config_option.required? and config[config_option.name].nil?
          log.error "#{self.class.name.split('::').last}: missing #{config_option.name} setting"
          valid = false
        end
      end
      valid
    end

    class ConfigOption < Struct.new(
      :name,
      :required,
      :default
    )
      alias_method :required?, :required
    end

    class << self
      def inherited(subclass)
        handlers << subclass
        super
      end

      def handlers
        @handlers ||= []
      end

      def config(*args)
				case args.length
				when 2;
					name = args[0]
					required = args[1][:required]
					default = args[1][:required]
					config_options << ConfigOption.new(name, required, default)
				when 1;
					default = args[0]
					config_options.each do |config_option|
						default[config_option.name] = config_option.default
					end
				end
      end

      def config_options
        @config_options ||= []
      end

      def disabled?
				config_options.respond_to?(:disabled) && config_options.disabled
      end
    end
  end
end
