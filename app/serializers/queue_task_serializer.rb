class UserSerializer < ActiveModel::Serializer

  # for #avatar_url to work, since it assumes image_path will work
  include ActionView::Helpers::AssetTagHelper

  format_keys :lower_camel
  root false

  attributes :sequence

  has_one :teacher, serializer: UserSerializer
  has_one :assistance_request, serializer: AssistanceRequestSerializer

end
