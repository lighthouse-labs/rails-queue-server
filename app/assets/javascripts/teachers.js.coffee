$ ->

  bind_readmore_to_feedbacks = (element) ->
    if element
      element.readmore
        speed: 75
        moreLink: '<a class="read-more-link" href="#">Read More</a>'
        lessLink: '<a class="read-more-link" href="#">Close</a>'
        collapsedHeight: 45
    else
      $('.read-more').readmore
        speed: 75
        moreLink: '<a class="read-more-link" href="#">Read More</a>'
        lessLink: '<a class="read-more-link" href="#">Close</a>'
        collapsedHeight: 45

  bind_readmore_to_feedbacks()

  $('.best_in_place').bind 'ajax:success', ->
    bind_readmore_to_feedbacks $(this).closest('.read-more')

  # For modifying mentor status of teachers:

  removeMentorship = (id, callback) ->
    $.ajax
      url: '/teachers/' + id + '/remove_mentorship'
      type: 'POST'
      success: callback

  addMentorship = (id, callback) ->
    $.ajax
      url: '/teachers/' + id + '/add_mentorship'
      type: 'POST'
      success: callback

  $('.remove-mentor-button').click (e) ->
    that = this
    $(this).attr('disabled', true)
    id = $('.teacher-mentor-status').data 'id'
    removeMentorship(id, ->
      $(that).addClass('d-none')
      $(that).attr('disabled', false)
      $('.make-mentor-button').removeClass('d-none'))

  $('.make-mentor-button').click (e) ->
    that = this
    $(this).attr('disabled', true)
    id = $('.teacher-mentor-status').data 'id'
    addMentorship(id, ->
      $(that).addClass('d-none')
      $(that).attr('disabled', false)
      $('.remove-mentor-button').removeClass('d-none'))