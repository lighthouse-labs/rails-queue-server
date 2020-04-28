class ZoomMeeting::CreateUserMeeting

  include Interactor::Organizer

  organize  ZoomMeeting::NewMeetingSetup,
            ZoomMeeting::CreateToken,
            ZoomMeeting::GetPoolUsers,
            ZoomMeeting::GetUser,
            ZoomMeeting::BookMeeting,
            ZoomMeeting::PushLicenseAdd,
            ZoomMeeting::UpdateUserLicense,
            ZoomMeeting::FindIdleLicense,
            ZoomMeeting::PushLicenseRemove,
            ZoomMeeting::UpdateUserLicense,
            ZoomMeeting::CreateVideoConference

end
