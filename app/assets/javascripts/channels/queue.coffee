# A Queue connection Manager
# Creates the ActionCable/WS subscription for the QueueChannel (server channel) and then
# Provides:
# 1. An interface to request the queue data on demand
# 2. The ability for react-based queue to register with this object (see @app)
# 3. A callback to registered queue func with any data changes broadcast from server

class Queue

  # @app is a pointer to the Queue.App react component
  #      and therefore expects to be able to call .setState() on it
  #      and must also support custom .connected() and .disconnected() functions

  constructor: ->
    @connected = false
    @app = null
    @connect()

  connect: ->
    return true if @connected
    @establishConnection()

  isConnected: ->
    @connected?

  establishConnection: () ->
    return false unless window.App
    $ =>
      return unless window.App.cable
      queue = this
      @channel = window.App.cable.subscriptions.create "QueueChannel",
        connected: ->
          queue.connected = true
          queue.app.connected() if queue.app

        disconnected: ->
          queue.connected = false
          queue.app.disconnected() if queue.app

        # Called when there's incoming data on the websocket for this channel
        received: (data) ->
          if data.type is 'AssistanceRequest'
            queue.handleNewAssistanceRequest(data.object)
          else if data.type is 'QueueUpdate'
            queue.handleDataReceived queue: data.queue

        sendMessage: (action, data) ->
          @perform action, data


  cancelAssistanceRequest: (request) ->
    @channel? && @channel.sendMessage 'cancel_assistance_request', request_id: request.id

  startAssisting: (request) ->
    @channel? && @channel.sendMessage 'start_assisting', request_id: request.id

  cancelAssisting: (assistance) ->
    @channel? && @channel.sendMessage 'cancel_assisting', assistance_id: assistance.id

  startEvaluating: (evaluation) ->
    @channel? && @channel.sendMessage 'start_evaluating', evaluation_id: evaluation.id

  cancelEvaluating: (evaluation) ->
    @channel? && @channel.sendMessage 'cancel_evaluating', evaluation_id: evaluation.id

  # for desktop notifications
  registerNotifier: (notifier) ->
    @notifier = notifier

  registerApp: (app) ->
    @app = app

  unregisterApp: ->
    @app = null

  fetch: ->
    $.getJSON('/queue.json').then(@handleDataReceived.bind(this))

  writeToCache: (data) ->
    window.localStorage.setItem 'queue', JSON.stringify(data.queue)

  readFromCache: ->
    data = localStorage.getItem 'queue'
    return JSON.parse(data) if data

  handleDataReceived: (data) ->
    @writeToCache(data)
    @app.setState(data) if @app

  handleNewAssistanceRequest: (request) ->
    @notifier.handleNewAssistanceRequest(request) if @notifier


window.App ||= {}
window.App.queue = new Queue(window.App.desktopNotifier)
