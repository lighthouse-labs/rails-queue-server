# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('body.project-evals-edit .actions').affix(
    offset:
      top: 800
  )

$ ->
  $(document).on 'click', '.btn-eval-feedback', ->
    $this = $(this)
    $this.closest('tr').next('tr.details').toggleClass('hide')

  $(document).on 'change', '#evaluation_form_final_score', (e) ->
    $this = $(this)
    console.log $this.val()
    if $this.val() == ''
      $('input.btn-evaluation[value="Reject"]').addClass('hide')
      $('input.btn-evaluation[value="Accept"]').addClass('hide')
    else if $this.val() == '1'
      $('input.btn-evaluation[value="Reject"]').removeClass('hide')
      $('input.btn-evaluation[value="Accept"]').addClass('hide')
    else
      $('input.btn-evaluation[value="Accept"]').removeClass('hide')
      $('input.btn-evaluation[value="Reject"]').addClass('hide')

$(document).on 'turbolinks:load', ->
  $('body.project-evals-show .actions').affix(
    offset:
      top: 300
      bottom: 200
  )
