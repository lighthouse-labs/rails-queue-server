class window.UserChannelHandler
  constructor: (data) ->
    @data = data
    @type = data?.type
    @object = data?.object

  processResponse: (callback) ->
    switch @type
      when "UserConnected"
        @userConnected()
      when "RedirectCommand"
        @redirectCommand()
      when "NewFeedback"
        @newFeedback()
      else
        new RequestButtonPresenter(@type, @object).render()

  connected: ->
    new RequestButtonPresenter('Connected').render()

  disconnected: ->
    new RequestButtonPresenter('Disconnected').render()

  redirectCommand: ->
    Turbolinks.visit(@data.location)

  newFeedback: ->
    $('nav .feedback-count').text(@object)
    $('nav .feedback-count').effect("bounce")

  userConnected: ->
    window.current_user = @object

    if(!App.teacherChannel || (App.teacherChannel && App.teacherChannel.consumer.connection.disconnected))
      # Connect to the teachers socket when we know the user has connected
      window.connectToTeachersSocket()
    
    if(!App.videoConferenceChannel || (App.videoConferenceChannel && App.videoConferenceChannel.consumer.connection.disconnected))
      window.connectToVideoConferenceSocket()