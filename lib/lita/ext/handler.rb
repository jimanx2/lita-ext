require 'lita'
require 'lita/handler'

module Lita
  class Handler

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
    end
  end
end
