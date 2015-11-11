window.App = {};
App.cable = Cable.createConsumer('ws://compass.dev:3000/websocket');

App.userChannel = App.cable.subscriptions.create("UserChannel", 
  requestAssistance: (reason) ->
    @perform 'request_assistance', reason: reason

  cancelAssistanceRequest: ->
    @perform 'cancel_assistance'

  received: (data) ->
    # For now these all do the same thing, but they may do other things
    switch data.type
      when "AssistanceRequested" then updateAssistanceUI() 
      when "AssistanceStarted" then updateAssistanceUI()
      when "AssistanceCancelled" then updateAssistanceUI()
      when "AssistanceEnded" then updateAssistanceUI()

)