$(document).on 'turbolinks:load', ->
  $('[data-toggle="tooltip"]').tooltip()
  Prism.highlightAll()
  # Activating Best In Place Editor
  $(".best_in_place").best_in_place();

  $('.chosen-select').chosen();

  $(document).on 'click', 'table thead a.select-all', (e) ->
    $this = $(this)
    num = $this.data('value')
    $this.closest('table').find("tbody td input[type=\"radio\"][value=\"#{num}\"]").click()
    false
