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

$(document).on 'turbolinks:load', ->
  $('body.project-evals-show .actions').affix(
    offset:
      top: 300
      bottom: 200
  )
