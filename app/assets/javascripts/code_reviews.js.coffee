$ ->

  $(document).on 'show.bs.modal', '#view_code_review_modal', (event) ->
    button = $(event.relatedTarget)
    codeReviewAssistanceId = button.data('code-review-assistance-id')
    modal = $(this)
    $.ajax(
      url: "code_reviews/#{codeReviewAssistanceId}"
      method: 'GET').done (info) ->
        modal.find('.view-modal-content').html(info)

  $(document).on 'show.bs.modal', '#new_code_review_modal', (event) ->
    button = $(event.relatedTarget)
    studentID = button.data('student-id')
    modal = $(this)
    $.ajax(
      url: "code_reviews/new?student_id=#{studentID}"
      method: 'GET').done (info) ->
        modal.find('.new-modal-content').html(info)
        initializeMarkdownEditor()
        validateForm()

  initializeMarkdownEditor = ->
    window.studentNotesEditor = ace.edit("student-notes")
    window.studentNotesEditor.setTheme("ace/theme/monokai")
    window.studentNotesEditor.getSession().setMode("ace/mode/markdown")

    $(document).on 'submit', '#new_assistance', (e) ->
      e.preventDefault()
      $('#assistance_student_notes').val(window.studentNotesEditor.getValue())
      this.submit()

  validateForm = ->
    $(document).on 'click', '#new-code-review-submit-button', (e) ->
      errrorMessages = []

      activity = $('#activity_submission_id')
      studentNotes = window.studentNotesEditor.getValue()
      teacherNotes = $('#code_review_notes')

      if activity.val() == ''
        errrorMessages.push('You must choose an activity to code review')
        activity.addClass('new-code-review-form-error')
      else if activity.hasClass('new-code-review-form-error')
        activity.removeClass('new-code-review-form-error')

      if studentNotes == ''
        errrorMessages.push('Student notes cannot be blank')

      if teacherNotes.val() == ''
        errrorMessages.push('Teacher notes cannot be blank')
        teacherNotes.addClass('new-code-review-form-error')
      else if teacherNotes.hasClass('new-code-review-form-error')
        teacherNotes.removeClass('new-code-review-form-error')

      if errrorMessages.length > 0
        e.preventDefault()
        $('.error-message').remove()
        errrorMessages.forEach (message) ->
          messageDiv = $('<div class="error-message">*' + message + '*</div>')
          messageDiv.css('color', 'tomato')
          messageDiv.prependTo '.modal-body'