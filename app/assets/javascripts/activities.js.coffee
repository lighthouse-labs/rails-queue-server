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