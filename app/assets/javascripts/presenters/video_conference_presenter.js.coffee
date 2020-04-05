class window.VideoConferencePresenter

  constructor: (object) ->
    @object = object
    @conference_nav = $('#video-conference-nav')
    @conference_nav_link = $('#video-conference-nav a')
    @conference_nav_badge = $('#video-conference-nav .conference-count')

  render: ->
    @videoConference = @object.videoConference
    switch @videoConference.status
      when "waiting" then @conferenceWaiting(@videoConference)
      when "broadcast" then @conferenceBroadcasting(@videoConference)
      when "finished" then @conferenceFinished(@videoConference)

  conferenceWaiting: (videoConference) ->
    if window.current_user.id == videoConference.userId
      @conference_nav.removeClass('d-none')
      @conference_nav.attr('title', 'Pending Conference')
      @activity_link = if videoConference.activityId then "/activities/#{videoConference.activityId}" else videoConference.joinUrl
      @conference_nav_link.attr('href', @activity_link)
      @conference_nav_badge.text('Test')
    else
      @conference_nav.addClass('d-none')
    
  conferenceBroadcasting: (videoConference) ->
    @conference_nav.removeClass('d-none')
    @conference_nav.attr('title', 'Live Conference')
    @activity_link = if videoConference.activityId then "/activities/#{videoConference.activityId}" else videoConference.joinUrl
    console.log(@activity_link)
    @conference_nav_link.attr('href', @activity_link)
    @conference_nav_badge.text('Live!')

  conferenceFinished: ->
    @conference_nav.addClass('d-none')