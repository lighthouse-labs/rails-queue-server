class ZoomMeeting::EndUserMeeting

  include Interactor::Organizer

  organize  ZoomMeeting::CreateToken,
            ZoomMeeting::EndMeeting,
            ZoomMeeting::GetPoolUsers,
            ZoomMeeting::GetUser,
            ZoomMeeting::PushLicenseRemove,
            ZoomMeeting::UpdateUserLicense

end
