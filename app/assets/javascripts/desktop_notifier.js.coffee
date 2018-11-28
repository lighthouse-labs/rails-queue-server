class DesktopNotifier
  constructor: ->
    @supportsNotifications = ("Notification" of window)
    @canNotify = false
    @checkNotificationSituation()

  checkNotificationSituation: ->
    return unless @supportsNotifications
    switch Notification.permission
      when "granted"
        @canNotify = true
      else
        @requestNotificationPermission()

  requestNotificationPermission: ->
    if @supportsNotifications
      Notification.requestPermission().then (res) =>
        if res is "granted"
          @canNotify = true

  handleNewAssistanceRequest: (assistanceRequest) ->
    if @supportsNotifications && @canNotify
      new Notification "Assistance Requested by " + assistanceRequest.requestor.firstName + ' ' + assistanceRequest.requestor.lastName, {
        body: "[Week " + assistanceRequest.requestor.cohort.week + "] " + (assistanceRequest.reason || ''),
        icon: assistanceRequest.requestor.avatarUrl
      }

window.App ||= {}
notifier = window.App.desktopNotifier = new DesktopNotifier
window.App.queue.registerNotifier(notifier)
