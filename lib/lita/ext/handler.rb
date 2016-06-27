require 'lita'
require 'lita/handler'

module Lita
  class Handler
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

      def config(name, required: true, default: nil)
        config_options << ConfigOption.new(name, required, default)
      end

      def config_options
        @config_options ||= []
      end

      def config(default)
        config_options.each do |config_option|
          default[config_option.name] = config_option.default
        end
      end

      def disabled?
        Lita.config.disabled.include?(namespace.to_sym)
      end
    end
  end
end
