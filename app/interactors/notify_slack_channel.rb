class NotifySlackChannel
  include Interactor

  before do
    @webhook = context.webhook
    @message = context.message
  end

  def call
    options    = {
      username: 'Compass',
      icon_url: 'https://cdn3.iconfinder.com/data/icons/browsers-1/512/Browser_JJ-512.png'
    }
    poster = Slack::Poster.new(@webhook, options)
    poster.send_message(@message)
  rescue StandardError => e
    # report but remain unaffected by any errors
    Raven.capture_exception(e)
    context.fail!(error: e.message)
  end

end