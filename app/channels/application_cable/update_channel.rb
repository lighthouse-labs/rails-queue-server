module ApplicationCable

  class UpdateChannel < ActionCable::Channel::Base

    @@message_sequence = 0
    @@general_updates = []
    @@user_updates = {}
    @@updates_type = 'Update'
    @@public_channel = 'public'
    @@max_updates_length = 10

    def self.broadcast_to(model, message, ignore = false)
      # add sequence number and store messages
      message[:sequence] = @@message_sequence += 1
      if message[:type] == @@updates_type && !ignore
        @@user_updates[model.id] ||= []
        @@user_updates[model.id].push({ object: message[:object], sequence: message[:sequence] })
        @@user_updates[model.id].shift(1) if @@user_updates[model.id].length > @@max_updates_length
      end
      super(model, message)
    end

    def self.broadcast(broadcasting, message, ignore = false)
      # add sequence number and store messages
      message[:sequence] = @@message_sequence += 1
      if broadcasting == @@public_channel && message[:type] == @@updates_type && !ignore
        @@general_updates.push({ object: message[:object], sequence: message[:sequence] })
        @@general_updates.shift(1) if @@general_updates.length > @@max_updates_length
      end
      ActionCable.server.broadcast broadcasting, message
    end

    def get_missed_updates(data)
      if current_user&.is_a?(Teacher)
        updates = [*@@general_updates, *@@user_updates[current_user.id]].sort_by { |update| update[:sequence] }
        sequence = data["sequence"] > @@message_sequence ? 0 : data["sequence"]
        updates = missed_updates(updates, sequence)
        if !updates.empty? && updates[0][:sequence] < sequence
          self.class.broadcast_to current_user, { type: @@updates_type, object: updates }, true
        else
          self.class.broadcast_to current_user, { type: 'refresh' }, true
        end
        # user has been sent updates so free up memory
        @@user_updates.delete(current_user.id)
      end
    end

    private

    def missed_updates(updates, sequence)
      updates.select do |hash|
        hash[:sequence] > sequence
      end
    end

  end

end
