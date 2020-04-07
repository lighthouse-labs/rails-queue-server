$ ->
  $(document).on 'click', '.copy-to-clipboard', (e) ->
    $('.copy-to-clipboard').attr("data-original-title", 'Copy to clipboard');
    $(this).attr("data-original-title", 'Copied!').tooltip('hide').tooltip('show');;
    temp = $("<input>");
    $("body").append(temp);
    temp.val($(this).siblings('.clip-content').find('a').text()).select();
    document.execCommand("copy");
    temp.remove();
