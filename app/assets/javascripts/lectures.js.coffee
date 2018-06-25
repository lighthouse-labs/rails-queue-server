$ ->
  $(document).on 'click', '.expand-search-options', (e) ->
    $(this).addClass('hidden')
    $(this).siblings('.extra-search-option').removeClass('hidden')
    $(this).siblings('.collapse-search-options').removeClass('hidden')

  $(document).on 'click', '.collapse-search-options', (e) ->
    $(this).addClass('hidden')
    $(this).siblings('.extra-search-option').addClass('hidden')
    $(this).siblings('.expand-search-options').removeClass('hidden')