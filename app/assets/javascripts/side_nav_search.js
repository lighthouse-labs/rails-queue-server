// Matching formula. Allows user to select activity by searching by grouping
// ex: w1d3 will return all w1d3 activities rather than just the title
function modelMatcher (params, data) {
  data.parentText = data.parentText || "";

  // Always return the object if there is nothing to compare
  if ($.trim(params.term) === '') {
    return data;
  }

  // Do a recursive check for options with children
  if (data.children && data.children.length > 0) {
    // Clone the data object if there are children
    // This is required as we modify the object to remove any non-matches
    var match = $.extend(true, {}, data);

    // Check each child of the option
    for (var c = data.children.length - 1; c >= 0; c--) {
      var child = data.children[c];
      child.parentText += data.parentText + " " + data.text;

      var matches = modelMatcher(params, child);

      // If there wasn't a match, remove the object in the array
      if (matches == null) {
        match.children.splice(c, 1);
      }
    }

    // If any children matched, return the new object
    if (match.children.length > 0) {
      return match;
    }

    // If there were no matching children, check just the plain object
    return modelMatcher(params, match);
  }

  // If the typed-in term matches the text of this term, or the text from any
  // parent term, then it's a match.
  var original = (data.parentText + ' ' + data.text).toUpperCase();
  var term = params.term.toUpperCase();


  // Check if the text contains the term
  if (original.indexOf(term) > -1) {
    return data;
  }

  // If it doesn't contain the term, don't return anything
  return null;
}

function ready() {

  $actSearch = ".activity-jump-to-dropdown";
  $($actSearch).prepend("<option value='' selected='selected'></option>");
  $($actSearch).select2({
    placeholder: "Find an activity",
    matcher: modelMatcher
  })
  $($actSearch).closest('.form-group').children('.select2-container').css({
    "margin-top": "10px",
    "maxWidth": "100%"
  });
  $($actSearch).on("select2:select", function (e) {
    document.location = "/" + e.params.data.id;
  })
};

$(document).ready(ready)
$(document).on('turbolinks:load', ready);