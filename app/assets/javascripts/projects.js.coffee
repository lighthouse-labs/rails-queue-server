$ ->
  appendEvals = (student, project, cohort) ->
    $.ajax
      url: `/projects/` + project.name + `student` + student.id

  $(document).on 'click', '#append-evals', (event) ->
    $(this).addClass('hidden-button')
    $(this).siblings('.hide-evals').removeClass('hidden-button')

  select = $('#project-feedback-dropdown option:selected').val()

  $('form').submit (e) ->
    e.preventDefault()
    el = $(this)
    $.ajax
      type: 'GET'
      url: el.data('url')
      data: $(this).serialize()
      success: (data) -> console.log data
