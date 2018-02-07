module CohortsHelper

  def cohort_link(cohort)
    if current_user && current_user.cohort == cohort
      cohort.name + " *"
    else
      cohort.name
    end
  end

  def cohort_status(cohort)
    if cohort.active?
      content_tag :span, 'Active', class: 'badge badge-success'
    elsif cohort.finished?
      content_tag :span, 'Finished', class: 'badge badge-danger'
    else
      content_tag :span, 'Upcoming', class: 'badge badge-info'
    end
  end

end
