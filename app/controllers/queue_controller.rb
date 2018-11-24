class QueueController < ApplicationController

  before_action :teacher_required

  def show
    respond_to do |format|
      format.html
      format.json {
        render json: QueueSerializer.new(current_user)
      }
    end
  end

  private

  def teacher_required
    unless teacher?
      respond_to do |format|
        format.html {
          redirect_to(:root, alert: 'Not allowed.')
        }
        format.json {
          render json: { error: 'Not Allowed.' }
        }
      end
    end
  end

end
