$ ->

  archiveDayFeedback = (id) ->
    $.ajax
      url: '/admin/day_feedbacks/' + id + '/archive'
      type: 'POST'

   unarchiveDayFeedback = (id) ->
     $.ajax
       url: '/admin/day_feedbacks/' + id + '/archive'
       type: 'DELETE'

  $(document).on 'click', '.archive-button', (e) ->
    $(this).siblings('.archive-confirm-button').show()
    $(this).hide()

  $(document).on 'click', '.archive-confirm-button', (e) ->
    id = $(this).parents('td').data 'id'
    archived_filter_status = $('#archived_').val()

    archiveDayFeedback(id)
    if archived_filter_status is 'false'
      $(this).closest('tr').hide(500)
    else
      $(this).hide()
      $(this).siblings('.unarchive-button').show()

  $(document).on 'click', '.unarchive-button', (e) ->
    id = $(this).parents('td').data 'id'
    $(this).hide()
    unarchiveDayFeedback(id)
    $(this).siblings('.archive-button').show()
