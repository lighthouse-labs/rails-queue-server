$ ->
  reactivateUser = (id) ->
    $.ajax
      url: '/admin/users/' + id + '/reactivate'
      type: 'POST'

  deactivateUser = (id) ->
    $.ajax
      url: '/admin/users/' + id + '/deactivate'
      type: 'POST'

  $(document).on 'click', '.user-reactivate-button', (e) ->
    id = $(this).parents('td').parents('tr').data 'id'
    reactivateUser(id)
    $(this).addClass('hidden-button')
    $(this).siblings('.user-deactivate-button').removeClass('hidden-button')
    $(this).closest('tr').find('.badge-light').addClass('hide')

  $(document).on 'click', '.user-deactivate-button', (e) ->
    id = $(this).parents('td').parents('tr').data 'id'
    deactivateUser(id)
    $(this).addClass('hidden-button')
    $(this).siblings('.user-reactivate-button').removeClass('hidden-button')
    $(this).closest('tr').find('.badge-light').removeClass('hide')
