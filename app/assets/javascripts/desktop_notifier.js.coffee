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

  onDuty: ->
    window.current_user.onDuty is on

  notificationBody: (request) ->
    week = request.requestor.cohort.week;
    "[Week #{week}] #{request.reason}\r\n(Notified b/c you're marked as on duty)"

  handleNewAssistanceRequest: (assistanceRequest) ->
    if @supportsNotifications && @canNotify && @onDuty()
      new Notification "Assistance Requested by " + assistanceRequest.requestor.firstName + ' ' + assistanceRequest.requestor.lastName, {
        body: @notificationBody(assistanceRequest),
        icon: assistanceRequest.requestor.avatarUrl
      }

window.App ||= {}
notifier = window.App.desktopNotifier = new DesktopNotifier
window.App.queue.registerNotifier(notifier)
