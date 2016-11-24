$ ->
  $('a[data-toggle="tab"]').on 'show.bs.tab', (e) ->
    localStorage.setItem 'activeTab', $(e.target).attr('href')
    return
  activeTab = localStorage.getItem('activeTab')
  if activeTab
    $('#studentTab a[href="' + activeTab + '"]').tab 'show'