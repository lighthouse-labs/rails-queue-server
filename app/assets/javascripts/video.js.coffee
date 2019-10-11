$(document).on 'turbolinks:load', ->
  if ($('#lecture-video').size() > 0)
    videojs 'lecture-video',
      playbackRates: [0.5, 1, 1.25, 1.5, 1.75, 1.88, 2],
      fluid: true