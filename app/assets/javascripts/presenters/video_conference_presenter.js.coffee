class window.VideoConferencePresenter

  constructor: (object) ->
    @object = object
    @conference_nav = $('#video-conference-nav')
    @conference_nav_link = $('#video-conference-nav a')
    @conference_nav_badge = $('#video-conference-nav .conference-count')

  render: ->
    console.log("recieved stuff", @object)
    @videoConference = @object.videoConference
    switch @videoConference.status
      when "waiting" then @conferenceWaiting(@videoConference)
      when "broadcast" then @conferenceBroadcasting(@videoConference)
      when "finished" then @conferenceEnded(@videoConference)

  conferenceWaiting: ->
    @conference_nav.removeClass('d-none')
    @conference_nav_link.attr('href', @object.activity ? "/activities/#{@object.activity_id}" : @object.join_url)
    @conference_nav_badge.text('?')

  conferenceBroadcasting: ->
    @conference_nav.removeClass('d-none')
    @conference_nav_link.attr('href', @object.join_url)
    @conference_nav_badge.text('!')

  conferenceFinished: ->
    @conference_nav.addClass('d-none')