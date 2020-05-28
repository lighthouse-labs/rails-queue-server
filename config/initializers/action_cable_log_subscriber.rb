class ActionCableLogSubscriber < ActiveSupport::LogSubscriber

  def perform_action(event)
    base_log = "#{event.payload[:channel_class]} - #{event.payload[:action]}"
    exception = event.payload[:exception_object]
    if exception
      Raven.capture_exception(exception)
      error "[Action Cable - Error] #{base_log} (Error: #{exception.message})"
    else
      info "[Action Cable] #{base_log}"
    end
  end

end

ActionCableLogSubscriber.attach_to :action_cable
