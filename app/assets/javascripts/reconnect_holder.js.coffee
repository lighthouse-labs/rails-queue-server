$ ->
  $(document).on 'click', '.reconnect-holder .reconnect', ->
    window.location.reload()

  $(document).on 'click', '.reconnect-holder .dismiss', ->
    $('.reconnect-holder').hide()