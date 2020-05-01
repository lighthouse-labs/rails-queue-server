
window.connectToTeachersSocket = ->
  return unless App.cable
  App.teacherChannel = App.cable.subscriptions.create "TeacherChannel",
    onDuty: (user) ->
      @perform 'on_duty', user_id: user && user.id

    offDuty: (user) ->
      @perform 'off_duty', user_id: user && user.id

    received: (data) ->
      new TeacherChannelHandler(data).processResponse()

    connected: ->
      new TeacherChannelHandler().connected()

    disconnected: ->
      new TeacherChannelHandler().disconnected()

window.connectToVideoConferenceSocket = ->
  return unless App.cable
  App.videoConferenceChannel = App.cable.subscriptions.create "VideoConferenceChannel",
    updateConference: (status, conferenceId) ->
      @perform 'update_conference', status: status, video_conference_id: conferenceId

    received: (data) ->
      new VideoConferenceChannelHandler(data).processResponse()

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
