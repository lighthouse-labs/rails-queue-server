class window.UserChannelHandler
  constructor: (data) ->
    @data = data
    @type = data.type
    @object = data.object

  processResponse: (callback) ->
    switch @type
      when "UserConnected"
        @userConnected()
      when "RedirectCommand"
        @redirectCommand()
      else
        presenter = new RequestButtonPresenter @type, @object
        presenter.render()

  redirectCommand: ->
    Turbolinks.visit(@data.location)

  userConnected: ->
    window.current_user = @object

    if(!App.teacherChannel || (App.teacherChannel && App.teacherChannel.consumer.connection.disconnected))
      # Connect to the teachers socket when we know the user has connected
      window.connectToTeachersSocket()
