$ ->

  $(document).on 'click', '.request-assistance-button', (e) ->
    e.preventDefault()
    reasonTextField = $(@).closest('form').find('textarea')
    reason = reasonTextField.val()
    activityId = $(@).closest('form').find('select').val()
    window.App.userChannel.requestAssistance(reason, activityId)
    reasonTextField.val('')

  $(document).on 'click', '.cancel-request-assistance-button', (e) ->
    e.preventDefault()
    e.stopPropagation()

    if confirm("Are you sure you want to withdraw this assistance request?")
      window.App.userChannel.cancelAssistanceRequest()

  $(document).on 'click', '.on-duty-link', (e) ->
    e.preventDefault()
    window.App.teacherChannel.onDuty()

    $('.on-duty-link').addClass('hidden')
    $('.off-duty-link').removeClass('hidden')

  $(document).on 'click', '.off-duty-link', (e) ->
    e.preventDefault()
    window.App.teacherChannel.offDuty()

    $('.off-duty-link').addClass('hidden')
    $('.on-duty-link').removeClass('hidden')

  $(document).on 'click', '.sign-out-link', (e) ->
    window.App.teacherChannel.offDuty()

  $(document).on 'click', '#search-activities-button', (e) ->
    $('#search-form').slideToggle(250, 'swing', focusOnSearchField)

  focusOnSearchField = ->
    inputField = $('#search-form').find('.search-input-field').find('input')
    if !(inputField.is(':hidden'))
      inputField.focus()

  if window.location.pathname == '/search_activities'
    $('#search-form').toggle()