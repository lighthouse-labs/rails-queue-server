class ZoomMeeting::FreeUserLicense

  include Interactor::Organizer

  organize  ZoomMeeting::CreateToken,
            ZoomMeeting::UpdateUserLicense

end
