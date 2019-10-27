class window.TeacherChannelHandler
  constructor: (data) ->
    @type = data?.type
    @object = data?.object

  connected: ->
    $('.off-duty-link, .on-duty-link').removeClass('disabled')

  disconnected: ->
    $('.off-duty-link, .on-duty-link').addClass('disabled')

  processResponse: ->
    switch @type
      when "UserConnected"
        @userConnected()
      when "TeacherOnDuty"
        @teacherOnDuty()
      when "TeacherOffDuty"
        @teacherOffDuty()
      when "TeacherBusy"
        @teacherBusy()
      when "TeacherAvailable"
        @teacherAvailable()

  userConnected: ->
    for teacher in @object
      @addTeacherToSidebar(teacher) if @teacherInLocation(teacher)

  teacherOnDuty: ->
    @addTeacherToSidebar(@object) if @teacherInLocation(@object)
    @markMeAsOnDuty() if @teacherIsMe(@object)

  teacherOffDuty: ->
    @removeTeacherFromSidebar(@object) if @teacherInLocation(@object)
    @markMeAsOffDuty() if @teacherIsMe(@object)

  teacherBusy: ->
    $('.teacher-holder').find('#teacher_' + @object.id).addClass('busy')

  teacherAvailable: ->
    $('.teacher-holder').find('#teacher_' + @object.id).removeClass('busy')

  teacherInLocation: (teacher) ->
    if current_user?.type is 'Teacher' or current_user?.cohort
      return current_user.location.id is teacher.location.id

  teacherIsMe: (teacher) ->
    window.current_user?.id is teacher.id

  markMeAsOnDuty: ->
    window.current_user.onDuty = true

  markMeAsOffDuty: ->
    window.current_user.onDuty = false

  addTeacherToSidebar: (teacher) ->
    if $('.teacher-images').find("\#teacher_#{teacher.id}").length is 0
      img = document.createElement('img')
      img.id = "teacher_#{teacher.id}"
      img.src = teacher.avatarUrl
      img.title = teacher.fullName
      img.setAttribute("data-placement", "bottom")

      link = document.createElement('a')
      link.href = "/teachers/#{teacher.id}"
      link.appendChild(img)

      img.className = 'busy' if teacher.busy

      $('.teacher-images').append(link)
      $(img).tooltip()

      teacherCount = $('.teacher-images').children().length
      $('.teacher-count').text($('.teacher-images').children().length);
      if teacherCount is 1
        $('.teacher-text').text(' Teacher on duty');
      else
        $('.teacher-text').text(' Teachers on duty');
      

  removeTeacherFromSidebar: (teacher) ->
    $('.teacher-images').find("\#teacher_#{teacher.id}").parent().remove()
    
    teacherCount = $('.teacher-images').children().length
    $('.teacher-count').text($('.teacher-images').children().length);
    if teacherCount is 1
      $('.teacher-text').text(' Teacher on duty');
    else
      $('.teacher-text').text(' Teachers on duty');