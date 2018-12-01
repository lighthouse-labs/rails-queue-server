# A Queue connection Manager
# Creates the ActionCable/WS subscription for the QueueChannel (server channel) and then
# Provides:
# 1. An interface to request the queue data on demand
# 2. The ability for a queue "view object" to register itself with this object (see @app notes below)
# 3. A callback to registered queue func with any data changes broadcast from server
# - KV

class Queue

  # @app is a pointer to an object that responds to
  #      .updateData(data)
  #      .connected() and
  #      .disconnected() state change functions
  #      In our case, the Queue.App react component is what we pass in
  # - KV

  constructor: ->
    @connected = false
    @app = null
    @connect()

  connect: ->
    return true if @connecting || @connected
    @connecting = true
    @establishConnection()

  isConnected: ->
    @connected?

  establishConnection: () ->
    return unless window.App?.cable
    return if @channel
    queue = this
    @channel = window.App.cable.subscriptions.create "QueueChannel",
      connected: ->
        queue.connected = true
        queue.connecting = false
        queue.app.connected() if queue.app

      disconnected: ->
        queue.connected = false
        queue.app.disconnected() if queue.app

      # Called when there's incoming data on the websocket for this channel
      received: (data) ->
        data = JSON.parse(data) if typeof(data) is 'string'
        if data.type is 'AssistanceRequest'
          queue.handleNewAssistanceRequest(data.object)
        else if data.type is 'QueueUpdate'
          queue.handleDataReceived queue: data.queue

      sendMessage: (action, data) ->
        @perform action, data

  cancelAssistanceRequest: (request) ->
    @channel?.sendMessage 'cancel_assistance_request', request_id: request.id

  startAssisting: (request) ->
    @channel?.sendMessage 'start_assisting', request_id: request.id

  cancelAssisting: (assistance) ->
    @channel?.sendMessage 'cancel_assisting', assistance_id: assistance.id

  startEvaluating: (evaluation) ->
    @channel?.sendMessage 'start_evaluating', evaluation_id: evaluation.id

  cancelEvaluating: (evaluation) ->
    @channel?.sendMessage 'cancel_evaluating', evaluation_id: evaluation.id

  cancelInterviewing: (interview) ->
    @channel?.sendMessage 'cancel_interviewing', interview_id: interview.id

  # for desktop notifications
  registerNotifier: (notifier) ->
    @notifier = notifier

  registerApp: (app) ->
    @app = app

  unregisterApp: ->
    @app = null

  fetch: (force=false) ->
    $.getJSON('/queue.json', force: force).then(@handleDataReceived.bind(this))

  writeToCache: (data) ->
    window.localStorage.setItem 'queue', JSON.stringify(data.queue) if data?.queue

  readFromCache: ->
    data = localStorage.getItem 'queue'
    return JSON.parse(data) if data

  handleDataReceived: (data) ->
    @writeToCache(data)
    @app.updateData(data) if @app

  handleNewAssistanceRequest: (request) ->
    @notifier.handleNewAssistanceRequest(request) if @notifier


window.App ||= {}
window.App.queue = new Queue(window.App.desktopNotifier)
