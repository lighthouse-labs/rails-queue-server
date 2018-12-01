class DesktopNotifier
  constructor: ->
    @supportsNotifications = ("Notification" of window)
    @permissionGranted = false
    @canNotifyGenerally = @checkIfNeedsNotifications()
    @checkNotificationSituation()

  checkNotificationSituation: ->
    return unless @supportsNotifications
    return unless @canNotifyGenerally
    switch Notification.permission
      when "granted"
        @permissionGranted = true
      else
        @requestNotificationPermission()

  requestNotificationPermission: ->
    if @supportsNotifications
      Notification.requestPermission().then (res) =>
        if res is "granted"
          @permissionGranted = true

  checkIfNeedsNotifications: ->
    window.current_user?.type is 'Teacher'

  onDuty: ->
    window.current_user.onDuty is on

  shouldNotifyNow: ->
    @supportsNotifications && @permissionGranted && @onDuty() && @needsNotifications

  notificationBody: (request) ->
    week = request.requestor.cohort.week;
    "[Week #{week}] #{request.reason}\r\n(Notified b/c you're marked as on duty)"

  handleNewAssistanceRequest: (assistanceRequest) ->
    if @shouldNotifyNow()
      new Notification "Assistance Requested by " + assistanceRequest.requestor.firstName + ' ' + assistanceRequest.requestor.lastName, {
        body: @notificationBody(assistanceRequest),
        icon: assistanceRequest.requestor.avatarUrl
      }

window.App ||= {}
notifier = window.App.desktopNotifier = new DesktopNotifier
window.App.queue.registerNotifier(notifier)
