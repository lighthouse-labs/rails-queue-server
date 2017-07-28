$ ->
  changeCohort = (studentID, cohortID) ->
    $.ajax
      url: '/admin/students/' + studentID
      data: { student: { cohort_id: cohortID } }
      type: 'PUT'

  changeMentor = (studentID, mentorID) ->
    $.ajax
      url: '/admin/students/' + studentID + '?mentor_id=' + cohortID
      type: 'PUT'

  toggleTechInterview = (element) ->
    if element.text() == "Enable Interviews"
      element.removeClass('btn-warning').addClass('btn-danger')
      element.text("Disable Interviews")
    else
      element.removeClass('btn-danger').addClass('btn-warning')
      element.text("Enable Interviews")

  $(document).on 'change', '.admin-student-cohort-selector', ->
    cohortID = $(this).val()
    newCohortName = $(this).find('option:selected').text()
    studentID = $(this).parents('td').parents('tr').data 'id'
    changeCohort(studentID, cohortID)
    $(this).parents('td')
      .html('<div class="admin-student-cohort-changed"> Cohort changed to ' +
        newCohortName + '! </div>')

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

  $(document).on 'click',
    '.admin-student-toggle-tech-interviews-btn', (event) ->
      element = $(event.target)
      contentURL = event.target.getAttribute('data-content-url')
      contentURL += '?toggle_tech_interviews=true'
      $.ajax(
        url: contentURL
        type: 'PUT').done (response) ->
          if response.status == "Success"
            toggleTechInterview(element)
