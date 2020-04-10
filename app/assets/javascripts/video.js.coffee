$(document).on 'turbolinks:before-visit', ->
  for player in $('.video-js')
    video = videojs(player)
    video.dispose()

$(document).on 'turbolinks:load', ->
  for player in $('.video-js')
    videojs player,
      playbackRates: [0.5, 1, 1.25, 1.5, 1.75, 1.88, 2],
      fluid: true