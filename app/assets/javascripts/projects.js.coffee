$ ->
  appendEvals = (student, project, cohort) ->
    $.ajax
      url: `/projects/` + project.name + `student` + student.id

  $(document).on 'click', '#append-evals', (event) ->
    $(this).addClass('hidden-button')
    $(this).siblings('.hide-evals').removeClass('hidden-button')
