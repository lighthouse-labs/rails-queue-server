function ready() {
  $actSearch = ".activity-search-dropdown";
  $($actSearch).prepend("<option value='' selected='selected'></option>");
  $($actSearch).select2({
    placeholder: "Search for an Activity",
  });
  $(".select2-container").css({
    "margin-top": "10px",
    "maxWidth": "100%",
  });
  $($actSearch).on("select2:select", function (e) {
    document.location = "/" + e.params.data.id;
  });
};

$(document).ready(ready)
$(document).on('turbolinks:load', ready);