class CohortPresenter < BasePresenter

  presents :cohort

  def cohort_link
    if admin?
      link_to cohort.name, [:admin, cohort]
    else
      cohort.name
    end
  end

  def cohort_students
    link_to 'Students', cohort_students_path(cohort_id: cohort), class: 'btn btn-xs btn-info'
  end

  def cohort_switcher
    link_to 'Select', [:switch_to, cohort], method: :put, class: 'btn btn-primary btn-xs'
  end

end
