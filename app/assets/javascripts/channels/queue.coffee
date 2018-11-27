# A Queue connection Manager
# Creates the ActionCable/WS subscription for the QueueChannel (server channel) and then
# Provides:
# 1. An interface to request queue payload on demand
# 2. Ability for react-based queue to register with this object
# 3. Callback to registered queue func with any data changes broadcast from server
class Queue

  constructor: ->
    @connected = false
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
          queue.app.setState(connected: true) if queue.app

        disconnected: ->
          queue.connected = false
          queue.app.setState(disconnects: queue.app.state.disconnects + 1, connected: false) if queue.app

        # Called when there's incoming data on the websocket for this channel
        received: (data) ->
          queue.dataReceived JSON.parse(data)

        sendMessage: (action, data) ->
          @perform action, data


  cancelAssistanceRequest: (request) ->
    @channel? && @channel.sendMessage 'cancel_assistance_request', request_id: request.id

  startAssisting: (request) ->
    @channel? && @channel.sendMessage 'start_assisting', request_id: request.id

  stopAssisting: (assistance) ->
    @channel? && @channel.sendMessage 'stop_assisting', assistance_id: assistance.id

  startEvaluating: (evaluation) ->
    @channel? && @channel.sendMessage 'start_evaluating', evaluation_id: evaluation.id

  cancelEvaluating: (evaluation) ->
    @channel? && @channel.sendMessage 'cancel_evaluating', evaluation_id: evaluation.id

  registerApp: (app) ->
    @app = app

  unregisterApp: ->
    @app = null

  fetch: ->
    $.getJSON('/queue.json').then(@dataReceived.bind(this))

  writeToCache: (data) ->
    window.localStorage.setItem 'queue', JSON.stringify(data.queue)

  readFromCache: ->
    data = localStorage.getItem 'queue'
    return JSON.parse(data) if data

  dataReceived: (data) ->
    @writeToCache(data)
    @app.setState(data) if @app

window.App ||= {}
window.App.queue = new Queue