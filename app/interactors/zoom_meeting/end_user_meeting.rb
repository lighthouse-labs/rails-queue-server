class ZoomMeeting::EndUserMeeting

  include Interactor::Organizer

  organize  ZoomMeeting::CreateToken,
            ZoomMeeting::EndMeeting,
            ZoomMeeting::UpdateUserLicense

end
