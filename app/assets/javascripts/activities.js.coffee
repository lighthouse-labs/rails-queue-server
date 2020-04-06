$ ->
  $(document).on 'click', '#student_submit_code_review_button', (event) ->
    hiddenGithubUrl = $('#hidden_github_url_input')
    visibleGithubUrl = $('#activity_submission_github_url')
    hiddenGithubUrl.val(visibleGithubUrl.val())

  # Feedback modal and inline feedback logic

  resetFeedbackForm = ->
    $('#activity_feedback_detail').val('')
    $('#activity_feedback_sentiment').val('')
    $('#activity_feedback_rating').val('')

  $(document).on('ajax:success', '#new_activity_feedback', (e, data, status, error) ->
    window.App.activityFeedbackApp && window.App.activityFeedbackApp.reset()
    $('.empty-message').hide()
    resetFeedbackForm()
  ).on 'ajax:error', (e, xhr, status, error) ->
    alert(xhr.responseText)

  $(document).on('ajax:success', '#new_activity_submission_with_optional_feedback', (e, data, status, xhr) ->
    $('.modal').hide();
    $('.modal-backdrop').hide();
    Turbolinks.visit(nextPath)
  ).on 'ajax:error', (e, xhr, status, error) ->
    $('#new_activity_submission_with_optional_feedback .remote-form-errors').removeClass('d-none').find('.error-messages').html xhr.responseText

