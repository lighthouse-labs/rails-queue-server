class window.VideoConferenceChannelHandler
  constructor: (data) ->
    @data = data
    @type = data?.type
    @object = data?.object

  processResponse: (callback) ->
    switch @type
      when "VideoConferenceUpdate"
        new VideoConferencePresenter(@object).render()