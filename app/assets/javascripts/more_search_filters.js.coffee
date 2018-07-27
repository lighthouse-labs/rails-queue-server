$ ->
  $(document).on 'click', '.expand-search-options', (e) ->
    $(this).addClass('hidden')
    $(this).closest('.search-form').find('.extra-search-option').removeClass('hidden').find('input, select').removeAttr('disabled')
    $(this).siblings('.collapse-search-options').removeClass('hidden')
    $('#advanced_search').val('1')
    e.preventDefault()

  $(document).on 'click', '.collapse-search-options', (e) ->
    $(this).addClass('hidden')
    $(this).closest('.search-form').find('.extra-search-option').addClass('hidden').find('input, select').attr('disabled', 'disabled')
    $(this).siblings('.expand-search-options').removeClass('hidden')
    $('#advanced_search').val('')
    e.preventDefault()