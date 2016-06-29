require 'lita'
require 'lita/handler'
require 'erubis'

module Lita

  class Handler
		
		attr_reader :view_paths
	
		def initialize(robot)
			@view_paths = [
				File.expand_path("app/views", Lita.root),
				File.expand_path("app/views/#{self.class.name.downcase}", Lita.root)
			]
			super
		end

		def render args = nil
			if args.is_a?(String)
				filename = args
			elsif args.is_a?(Hash)
				filename = args[:template] if args.key? :template
			end

			filename ||= caller[0][/`.*'/][1..-2]

			@view_paths.each do |viewpath|
				path = "#{viewpath}/#{filename}.erb"
				@file = path if File.exists? path
			end
			raise "Template '#{filename}.erb' could not be found. Searched in:\n#{@view_paths}" unless @file
			eruby = Erubis::Eruby.new( File.read(@file) )
			eruby.result(instance_variables.map {|x|
				{ x.to_sym => instance_variable_get(x) }
			}.reduce({}, :merge))
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
    end
  end
end
