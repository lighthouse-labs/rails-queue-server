$ ->
  document.addEventListener 'turbolinks:load', (event) ->
    ga('set', 'location', event.data.url)
    ga('send', 'pageview')