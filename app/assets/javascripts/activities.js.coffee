$ ->
  $(document).on 'click', '#student_submit_code_review_button', (event) ->
    hiddenGithubUrl = $('#hidden_github_url_input')
    visibleGithubUrl = $('#activity_submission_github_url')
    hiddenGithubUrl.val(visibleGithubUrl.val())

  $(document).on 'click', '#show-objectives-button', (event) ->
    $(this).toggle()
    $(this).siblings('#hide-objectives-button').css('display', 'inline-block')
    $(this).siblings('.day-objectives-holder').toggle()

  $(document).on 'click', '#hide-objectives-button', (event) ->
    $(this).toggle()
    $(this).siblings('#show-objectives-button').css('display', 'inline-block')
    $(this).siblings('.day-objectives-holder').toggle()

  resetFeedbackForm = ->
    $('#activity_feedback_detail').val('')
    $('#activity_feedback_sentiment').val('')
    $('#activity_feedback_rating').val('')

  $('#new_activity_feedback').on('ajax:success', (e, data, status, error) ->
    $('#activity-feedback > ul').prepend(data)
    $('.empty-message').hide()
    resetFeedbackForm()
  ).on 'ajax:error', (e, xhr, status, error) ->
    alert(xhr.responseText)

  $("#new_activity_submission_with_optional_feedback").on("ajax:success", (e, data, status, xhr) ->
    window.location.href = nextPath
  ).on "ajax:error", (e, xhr, status, error) ->
    $("#new_activity_submission_with_optional_feedback .remote-form-errors").removeClass('d-none').find('.error-messages').html xhr.responseText

