$ ->
  reactivateUser = (id) ->
    $.ajax
      url: '/admin/users/' + id + '/reactivate'
      type: 'POST'

  deactivateUser = (id) ->
    $.ajax
      url: '/admin/users/' + id + '/deactivate'
      type: 'POST'

  impersonate = (id) ->
    $.ajax
      url: '/session/impersonate?id=' + id
      type: 'PUT'

  assignCohort = (id, code) ->
    $.ajax
      url: '/admin/users/' + id + '/assign_cohort?code=' + code
      type: 'POST'

  revertToPrep = (id) ->
    $.ajax
      url: '/admin/students/' + id
      type: 'DELETE'
      data: { confirm: 'Are you sure?' }

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

  $(document).on 'click', '.user-impersonate-button', (e) ->
    id = $(this).parents('td').parents('tr').data 'id'
    impersonate(id)

  $(document).on 'click', '.assign-cohort-button', (e) ->
    id = $(this).parents('td').parents('tr').data 'id'
    code = $(this).siblings('.cohort').val()
    assignCohort(id, code)
    $(this).addClass('hidden-button')
    $(this).siblings('.cohort').addClass('hidden-button')
    $(this).siblings('.revert-to-prep-button').removeClass('hidden-button')

  $(document).on 'click', '.revert-to-prep-button', (e) ->
    id = $(this).parents('td').parents('tr').data 'id'
    revertToPrep(id)
    $(this).addClass('hidden-button')
    $(this).siblings('.assign-cohort-button').removeClass('hidden-button')
