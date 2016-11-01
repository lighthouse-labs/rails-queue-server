$ ->

  reactivateStudent = (id) ->
    $.ajax
      url: '/admin/users/' + id + '/reactivate'
      type: 'POST'

  deactivateStudent = (id) ->
    $.ajax
      url: '/admin/users/' + id + '/deactivate'
      type: 'POST'

  changeCohort = (studentID, cohortID) ->
    $.ajax
      url: '/admin/students/' + studentID
      data: { student: { cohort_id: cohortID } }
      type: 'PUT'

  changeMentor = (studentID, mentorID) ->
    $.ajax
      url: '/admin/students/' + studentID + '?mentor_id=' + cohortID
      type: 'PUT'

  $(document).on 'click', '.student-reactivate-button', (e) ->
    id = $(this).parents('td').parents('tr').data 'id'
    reactivateStudent(id)
    $(this).addClass('hidden-button')
    $(this).siblings('.student-deactivate-button').removeClass('hidden-button')
    $(this).closest('tr').find('.label-deactivated').addClass('hide')

  $(document).on 'click', '.student-deactivate-button', (e) ->
    id = $(this).parents('td').parents('tr').data 'id'
    deactivateStudent(id)
    $(this).addClass('hidden-button')
    $(this).siblings('.student-reactivate-button').removeClass('hidden-button')
    $(this).closest('tr').find('.label-deactivated').removeClass('hide')

  $(document).on 'change', '.admin-student-cohort-selector', ->
    cohortID = $(this).val()
    newCohortName = $(this).find('option:selected').text()
    studentID = $(this).parents('td').parents('tr').data 'id'
    changeCohort(studentID, cohortID)
    $(this).parents('td').html('<div class="admin-student-cohort-changed"> Cohort changed to ' + newCohortName + '! </div>')

  $(document).on 'show.bs.modal', '#student-actions-modal', (event) ->
    button = $(event.relatedTarget)
    studentID = button.data('student-id')
    modal = $(this)
    modal.find('.modal-content').html('')
    $.ajax(
      url: '/admin/students/'+studentID+'/modal_content'
      method: 'GET').done (info) ->
        modal.find('.modal-content').html(info)

  $(document).on 'show.bs.modal', '#student-rollover-modal', (event) ->
    button = $(event.relatedTarget)
    contentURL = button.data('content-url')
    modal = $(this)
    modal.find('.modal-content').html('')
    $.ajax(
      url: contentURL
      method: 'GET').done (info) ->
        modal.find('.modal-content').html(info)
