# Turn off wrapper div of class "field_with_errors" around form inputs (Rails default behavior)
ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  html_tag.html_safe
end
