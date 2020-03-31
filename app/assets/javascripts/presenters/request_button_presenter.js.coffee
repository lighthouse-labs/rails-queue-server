class window.RequestButtonPresenter

  constructor: (type, object) ->
    @type = type
    @object = object
    @ar_create = $('#create-assistance-request')
    @ar_create_button = @ar_create.find('button')
    @ar_cancel = $('#cancel-assistance-request')
    @ar_conference = $('#assistance-request-conference')
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
    @ar_create_button.attr('disabled', 'disabled')
    @ar_cancel_button.attr('disabled', 'disabled')

  enable: ->
    @ar_create_button.removeAttr('disabled')
    @ar_cancel_button.removeAttr('disabled')

  updateQueuePosition: (position) ->
    @ar_conference.addClass('d-none')
    @ar_cancel_button.text('No. ' + position + ' in Request Queue')

  assistanceStarted: (data) ->
    @assistor = data.assistor
    @conference_link = data.conference

    if @conference_link
      @ar_conference.removeClass('d-none')
      @ar_conference.attr('href', @conference_link)

    @ar_cancel_button.text('assisting')
    @ar_cancel_button.text(@assistor.firstName + ' ' + @assistor.lastName + ' assisting')

  assistanceEnded: ->
    @ar_create.removeClass('d-none')
    @ar_cancel.addClass('d-none')
    @ar_conference.addClass('d-none')

  assistanceRequested: (position) ->
    @ar_create.addClass('d-none')
    @ar_cancel.removeClass('d-none')
    @ar_cancel_button.text('No. ' + position + ' in Request Queue')
    @ar_cancel_button.tooltip()

