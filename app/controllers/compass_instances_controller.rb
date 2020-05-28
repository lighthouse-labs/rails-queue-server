class CompassInstancesController < ApplicationController

  before_action :queue_admin_required
  skip_before_action :authenticate_user

  def create
    compass_instance = CompassInstance.new(compass_instance_params)
    file = File.join(Rails.root, 'config', 'default_router_settings.json')
    default_settings = JSON.parse File.read(file)

    compass_instance.settings = { task_router_settings: default_settings }
    compass_instance.key = SecureRandom.hex(8)
    secret = SecureRandom.hex(16)
    compass_instance.secret = BCrypt::Password.create(secret)

    if compass_instance.save!
      render json: { key: compass_instance.key, secret: secret }
    else
      render json: { error: 'Something Went Wrong.' }
    end
  end

  private

  def compass_instance_params
    params.require(:compass_instance).permit(:name, :database, :type)
  end

  def queue_admin_required
    render json: { error: 'Invalid Admin password.' } unless params[:admin_password] == ENV["ADMIN_PASSWORD"]
  end

end
