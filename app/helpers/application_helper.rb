module ApplicationHelper

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
  end

  def fools?
    Date.current.month == 4 && Date.current.day == 1
  end

  def disable_cable?
    current_user.nil? || !current_user.active? || current_user.prospect? ||
      (current_user.cohort && current_user.cohort.limited?)
  end

  # folks in limited (previous alumni) cohort dont need to take up action cable connections
  def disable_cable_for_some
    ' disable-cable' if disable_cable?
  end

  # Display an integer time as a string
  # Ex: integer_time_to_s(930) # => "9:30"
  def integer_time_to_s(int_time)
    return nil if int_time.blank?
    hours = int_time / 100
    minutes = int_time % 100
    minutes = "00" if minutes == 0
    return "#{hours}:#{minutes}"
  end

  def avatar_for(user)
    if user.custom_avatar.url
      user.custom_avatar.url(:thumb)
    else
      user.avatar_url
    end
  end

  def format_date_time(time)
    time ? time.strftime("%b %e, %l:%M %p") : ''
  end

  def it_is_6pm_already?
    Time.current.seconds_since_midnight >= DAY_FEEDBACK_AFTER
  end

  def link_to_add_fields(name, f, association, css_classes)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_fields btn btn-primary btn-sm #{css_classes}", data: {id: id, fields: fields.gsub("\n", "")})
  end

  def shortened_github_url(url)
    url.gsub(/https?\:\/\/(www\.)?github.com\//, '')
  end

  def progress_bar_class(percent)
    if percent >= 96
      'progress-bar-success'
    elsif percent > 70
      'progress-bar-info'
    elsif percent > 50
      'progress-bar-warning'
    else
      'progress-bar-danger'
    end
  end

  def l_score_label_class(val)
    return 'label-default' if val.nil?
    val = val.to_f

    if val < 2.1
      'label-danger'
    elsif val < 2.4
      'label-warning'
    elsif val < 2.8
      'label-info'
    elsif val <= 4.0
      'label-success'
    else
      'label-default'
    end
  end

  def integer_l_score_label_class(val)
    return 'label-default' if val.nil?

    if val < 2
      'label-danger'
    elsif val < 3
      'label-warning'
    elsif val < 4
      'label-info'
    elsif val == 4
      'label-success'
    end
  end


end
