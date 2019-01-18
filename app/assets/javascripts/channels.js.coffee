
window.connectToTeachersSocket = ->
  return unless App.cable
  App.teacherChannel = App.cable.subscriptions.create "TeacherChannel",
    onDuty: ->
      @perform 'on_duty'

    offDuty: ->
      @perform 'off_duty'

    received: (data) ->
      new TeacherChannelHandler(data).processResponse()

    connected: ->
      new TeacherChannelHandler().connected()

    disconnected: ->
      new TeacherChannelHandler().disconnected()

$ ->
  return unless App.cable
  App.userChannel = App.cable.subscriptions.create "UserChannel",
    connected: ->
      new UserChannelHandler().connected();
      if $('.reconnect-holder').is(':visible')
        $('.reconnect-holder').hide()
        eventClass = navigator.onLine ? 'reconnect-online' : 'reconnect-offline'
        ga('send', 'event', 'queue-connection', eventClass)

    requestAssistance: (reason, activityId) ->
      @perform 'request_assistance', reason: reason, activity_id: activityId

    cancelAssistanceRequest: ->
      @perform 'cancel_assistance'

    received: (data) ->
      handler = new UserChannelHandler data
      handler.processResponse()

    disconnected: ->
      new UserChannelHandler().disconnected();
      eventClass = navigator.onLine ? 'disconnect-online' : 'disconnect-offline'
      ga('send', 'event', 'queue-connection', eventClass)
      $('.reconnect-holder').delay(500).show(0)
