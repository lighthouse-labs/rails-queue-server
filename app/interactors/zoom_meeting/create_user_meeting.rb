class ZoomMeeting::CreateUserMeeting

  include Interactor::Organizer

  organize  ZoomMeeting::CreateToken,
            ZoomMeeting::GetPoolUsers,
            ZoomMeeting::GetUser,
            ZoomMeeting::FindIdleLicense,
            ZoomMeeting::UpdateUserLicense,
            ZoomMeeting::BookMeeting

end
