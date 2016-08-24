$ ->
  $('[data-toggle="tooltip"]').tooltip()
  Prism.highlightAll()

  $('table thead a.select-all').click ->
    $this = $(this)
    num = $this.data('value')
    $this.closest('table').find("tbody td input[type=\"radio\"][value=\"#{num}\"]").click()
    false