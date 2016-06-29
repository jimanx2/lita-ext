class Lita::Message
	attr_accessor :raw, :metadata
	
	def initialize(robot, body, source)
		@robot = robot
		@body = body
		@source = source
		@extensions = {}

		name_pattern = "@?#{Regexp.escape(@robot.mention_name)}[:,]?\\s+"
		alias_pattern = "#{Regexp.escape(@robot.alias)}\\s*" if @robot.alias
		command_regex = if alias_pattern
			/\A\s*(?:#{name_pattern}|#{alias_pattern})/i
		else
			/\A\s*#{name_pattern}/i
		end

		@command = !!@body.sub!(command_regex, "")
	end
	
	def update varname, value
		instance_variable_set(varname, value)
	end
	
end