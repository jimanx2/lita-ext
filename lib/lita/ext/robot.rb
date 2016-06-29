require 'lita'
require 'lita/metadata'
require 'lita/robot'

class Lita::Robot
	def send_messages(target, *messages)
		queue = []
		messages.each.with_index do |message, i|
			if messages[i].is_a?(Hash)
				messages[i][:metadata] = Lita::Metadata.create({
					message_id: -1,
					content: MultiJson.dump(messages[i][:metadata]),
					room_id: target.room.to_i
				}) if messages[i][:metadata]
			end
			queue << message
		end
		
		adapter.send_messages(target, queue)
	end
	
	def receive(message)
		
		unless message.raw.nil?
			raw = message.raw
			
			if raw.class.name.match('Telegram::Bot::Types::Message')
				case raw.chat.type.to_sym
					when :private;
						meta = Lita::Metadata.find(room_id: raw.chat.id)
							.sort_by(:message_id, :order => "DESC")
							.first
						metadata = MultiJson.load(meta.content) if meta
						meta.delete if meta
					when :supergroup, :group;
						meta = Lita::Metadata.find(message_id: raw.reply_to_message.message_id).first \
							if raw.reply_to_message
						metadata = MultiJson.load(meta.content) if meta
				end
			end
			
		else
			meta = Lita::Metadata.find(message_id: -1).first
			unless meta.nil?
				metadata = MultiJson.load(meta.content)
				meta.delete
			end
		end
		
		unless metadata.nil?
			message.update("@body", "#{metadata["next"]} #{message.body}")
			message.update("@metadata", metadata)
		end
		
		trigger(:message_received, message: message)
		matched = handlers.map do |handler|
			next unless handler.respond_to?(:dispatch)
			handler.dispatch(self, message)
		end.any?

		trigger(:unhandled_message, message: message) unless matched
	end
end