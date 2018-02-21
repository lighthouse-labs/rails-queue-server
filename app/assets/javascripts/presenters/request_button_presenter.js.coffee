class window.RequestButtonPresenter
  constructor: (type, object) ->
    @type = type
    @object = object
    @ar_create = $('#create-assistance-request')
    @ar_create_button = @ar_create.find('button')
    @ar_cancel = $('#cancel-assistance-request')
    @ar_cancel_button = @ar_cancel.find('a')

  render: ->
    switch @type
      when "AssistanceRequested" then @assistanceRequested(@object) 
      when "AssistanceStarted" then @assistanceStarted(@object)
      when "AssistanceEnded" then @assistanceEnded()
      when "QueueUpdate" then @updateQueuePosition(@object)

  updateQueuePosition: (position) ->
    @ar_cancel_button.text('No. ' + position + ' in Request Queue')

  assistanceStarted: (assistor) ->
    @ar_cancel_button.text(assistor.first_name + ' ' + assistor.last_name + ' assisting')

  assistanceEnded: ->
    @ar_create.removeClass('d-none')
    @ar_cancel.addClass('d-none')

  assistanceRequested: (position) ->
    @ar_create.addClass('d-none')
    @ar_cancel.removeClass('d-none') 
    @ar_cancel_button.text('No. ' + position + ' in Request Queue')
    @ar_cancel_button.tooltip()



