$ ->
  # activity uuid, retrieved from DOM
  uuid = null

  # timers for ajax PUT to save answers on server side
  # object because a given activity can have many savable questions
  # key (unique question key) => value (user's answer text)
  timers = {}

  # for toggles where an answer is not needed, we don't have a data-key attribute
  $(document).on 'click', '.togglable-solution:not([data-key]) button.toggle-answer', (evt) ->
    $(this).closest(".togglable-solution").find(".answer").slideToggle()

  ####
  # code below deals with cases where an answer IS needed for the togglable-answer
  ####

  saveAnswer = (elm, key, answer) ->
    key = encodeURIComponent(key)
    $.ajax "/activities/#{uuid}/answers/#{key}", { type: 'PUT', data: { answer_text: answer } }
      .fail (err, textStatus, third) ->
        alert('ERROR. Failed to save answer to server. Please copy/paste your answer somewhere safe and try again after a few seconds by updating your answer text slightly.')

  changeButtonDisabledState = (elm, answer) ->
    if answer? && answer.trim().length > 2
      elm.find('button.toggle-answer').removeClass('disabled').removeAttr('disabled')
    else
      elm.find('button.toggle-answer').addClass('disabled').attr('disabled', 'disabled')

  changeAnswerDisabledState = (elm, toggled) ->
    if (toggled)
      elm.addClass('answer-locked')
      elm.find('textarea').addClass('disabled').attr('disabled', 'disabled')
    else
      elm.removeClass('answer-locked')
      elm.find('textarea').removeClass('disabled').removeAttr('disabled')

  populateAnswer = (activityAnswer) ->
    $tAnswer = $(".togglable-solution[data-key=\"#{activityAnswer.question_key}\"]")
    $textarea = $tAnswer.find('textarea')
    $textarea.val(activityAnswer.answer_text)

    # height adjustment
    autosize.update($textarea)

    # state adjustments (textarea and/or toggle buttons can be disabled)
    changeButtonDisabledState($tAnswer, activityAnswer.answer_text)
    changeAnswerDisabledState($tAnswer, activityAnswer.toggled)

  handleAnswerChange = (elm, key, evt) ->
    $textarea = $(evt.target)

    timer = timers[key]
    clearTimeout(timer) if timer?

    val = $textarea.val()
    changeButtonDisabledState elm, val

    timers[key] = setTimeout saveAnswer.bind(this, elm, key, val), 1000


  setupInteractiveToggleAnswer = (elm, key) ->
    elm.find('textarea').on 'input', (evt) ->
      handleAnswerChange(elm, key, evt)

    elm.find('button.toggle-answer').on 'click', ->
      answerText = elm.find('textarea').val()

      if elm.hasClass('answer-locked')
        elm.find(".answer").slideToggle()
      else if (!elm.find('.answer').is(':visible') && confirm("Commit your answer? You won't be able to update your answer after showing the correct answer."))
        changeAnswerDisabledState(elm, true)
        elm.find(".answer").slideToggle()
        $.ajax "/activities/#{uuid}/answers/#{key}", { type: 'PUT', data: { toggled: true, answer_text: answerText } }

  $(document).on 'turbolinks:load', (event) ->
    activityDetails = $('.activity-details')
    return if activityDetails.size() == 0
    uuid = activityDetails.first().data('uuid')
    return unless uuid?

    # disable all toggle answers that don't have a value
    $('.togglable-solution[data-key] button.toggle-answer').addClass('disabled').attr('disabled', 'disabled')

    # fetch and populate all answers
    $.getJSON("/activities/#{uuid}/answers")
      .done (data) ->
        populateAnswer answer for answer in data.activity_answers

    # register each one to handle answer input
    activityDetails.find('.togglable-solution[data-key]').each (i, elm) ->
      $elm = $(elm)
      key = $elm.data('key')
      setupInteractiveToggleAnswer($elm, key) if key?

