class window.RequestButtonPresenter

  constructor: (type, object) ->
    @type = type
    @object = object
    @ar_create = $('#create-assistance-request')
    @ar_create_button = @ar_create.find('button')
    @ar_cancel = $('#cancel-assistance-request')
    @ar_cancel_button = @ar_cancel.find('button')

  render: ->
    switch @type
      when "AssistanceRequested" then @assistanceRequested(@object)
      when "AssistanceStarted" then @assistanceStarted(@object)
      when "AssistanceEnded" then @assistanceEnded()
      when "QueuePositionUpdate" then @updateQueuePosition(@object)
      when "Disconnected" then @disable()
      when "Connected" then @enable()

  disable: ->
    @ar_create_button.addClass('disabled')
    @ar_cancel_button.addClass('disabled')

  enable: ->
    @ar_create_button.removeClass('disabled')
    @ar_cancel_button.removeClass('disabled')

  updateQueuePosition: (position) ->
    @ar_cancel_button.text('No. ' + position + ' in Request Queue')

  assistanceStarted: (assistor) ->
    @ar_cancel_button.text(assistor.firstName + ' ' + assistor.lastName + ' assisting')

  assistanceEnded: ->
    @ar_create.removeClass('d-none')
    @ar_cancel.addClass('d-none')

  assistanceRequested: (position) ->
    @ar_create.addClass('d-none')
    @ar_cancel.removeClass('d-none')
    @ar_cancel_button.text('No. ' + position + ' in Request Queue')
    @ar_cancel_button.tooltip()

