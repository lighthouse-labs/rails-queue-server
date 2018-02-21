$ ->

  $(document).on 'click', '.ask-question', (e) ->
    $btn = $(this);
    if $btn.hasClass 'active'
      console.log('de-activating')
      $btn.removeClass 'active'
      $btn.text $btn.data('default-text')
      $('.hide-for-student').removeClass 'active'
    else
      console.log('activating')
      $btn.addClass 'active'
      $btn.text $btn.data('active-text')
      $('.hide-for-student').addClass 'active'

# $(document).on 'turbolinks:load', ->
  # $('body.tech-interview-on .actions').affix(
  #   offset:
  #     top: 300
  #     bottom: 200
  # )