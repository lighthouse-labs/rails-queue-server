# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  # $('body.project-evals-edit .actions').affix(
  #   offset:
  #     top: 800
  # )

  autosize($('body.project-evals-edit-new textarea'))

$ ->

  evalSaveTimeout = null

  saveEval = ->
    $form = $('form.edit_evaluation')
    $.rails.handleRemote($form)

  queueSaveEval = ->
    clearTimeout(evalSaveTimeout) if evalSaveTimeout
    evalSaveTimeout = setTimeout(saveEval, 300)

  # Text Feedback becomes required if score is below acceptable (3)
  checkFeedbackRequired = () ->
    $this = $(this)
    val   = $this.val()
    $card = $this.closest('.card')
    if (val == '1' || val == '2')
      $card.find('textarea').attr('required', 'required')
      $card.find('span.required-notice').removeClass('invisible')
    else
      $card.find('textarea').removeAttr('required')
      $card.find('span.required-notice').addClass('invisible')

  checkIfRejecting = () ->
    rejecting = false
    $notice = $('.alert.rejection-notice')

    $('body.project-evals-edit-new input[type="radio"]:checked').each (i, elm) ->
      $elm = $(elm)
      if $elm.val() == '1' && $elm.closest('.card').data('affects-outcome') == 1
        rejecting = true

    if rejecting
      $notice.removeClass 'invisible'
    else
      $notice.addClass 'invisible'

  $(document).on 'change', 'body.project-evals-edit-new input[type="radio"]', saveEval
  $(document).on 'change', 'body.project-evals-edit-new input[type="radio"]', checkFeedbackRequired
  $(document).on 'change', 'body.project-evals-edit-new input[type="radio"]', checkIfRejecting
  $(document).on 'input', 'body.project-evals-edit-new textarea', queueSaveEval

$ ->
  $(document).on 'click', '.btn-eval-feedback', ->
    $this = $(this)
    $this.closest('tr').next('tr.details').toggleClass('hide')

  $(document).on 'change', '#evaluation_form_final_score', (e) ->
    $this = $(this)
    if $this.val() == ''
      $('input.btn-evaluation[value="Reject"]').addClass('hide')
      $('input.btn-evaluation[value="Accept"]').addClass('hide')
    else if $this.val() == '1'
      $('input.btn-evaluation[value="Reject"]').removeClass('hide')
      $('input.btn-evaluation[value="Accept"]').addClass('hide')
    else
      $('input.btn-evaluation[value="Accept"]').removeClass('hide')
      $('input.btn-evaluation[value="Reject"]').addClass('hide')

# $(document).on 'turbolinks:load', ->
#   $('body.project-evals-show .actions').affix(
#     offset:
#       top: 300
#       bottom: 200
#   )
