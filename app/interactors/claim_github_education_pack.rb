class ClaimGithubEducationPack

  include Interactor

  before do
    @user = context.user
  end

  def call
    student_id = @user.unique_id
    school_id = ENV['GITHUB_EDUCATION_SCHOOL_ID']
    secret_key = ENV['GITHUB_EDUCATION_SECRET_KEY']
    signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret_key, school_id + student_id)
    context.url = "https://education.github.com/student/verify?school_id=#{school_id}&student_id=#{URI.escape(student_id)}&signature=#{URI.escape(signature)}"

    unless @user.update(github_education_action: 'claimed', github_education_action_at: Time.current)
      context.fail!(error: @user.errors.full_messages.first)
    end
  end

end

