class Admin::UsersController < Admin::BaseController

  before_action :load_user, only: [:reactivate, :deactivate]

  DEFAULT_PER = 25

  def index
    @users = User.all.includes(:location, :cohort).order(id: :desc).page(params[:page]).per(DEFAULT_PER)
    apply_filters
  end

  def reactivate
    @user.reactivate!
    render nothing: true
  end

  def deactivate
    @user.deactivate!
    render nothing: true
  end

  private

  def load_user
    @user = User.find(params[:id])
  end

  def apply_filters
    filter_by_status
    filter_by_type
    filter_by_location
    filter_by_admin
    filter_by_keywords
  end

  def filter_by_status
    params[:status] ||= 'All'
    @users = case params[:status]
             when 'Active'
               @users.active
             when 'Deactivated'
               @users.deactivated
             else
               @users
    end
  end

  def filter_by_type
    params[:type] ||= 'All'
    @users = case params[:type]
             when 'Teacher'
               @users.where(type: 'Teacher')
             when 'Student'
               @users.where(type: 'Student').where.not(cohort_id: nil)
             when 'Prep Only'
               @users.where(type: [nil, 'Student']).where(cohort_id: nil)
             else
               @users
    end
  end

  def filter_by_location
    return if params[:location_id].blank?
    @users = @users.where(location_id: params[:location_id])
  end

  def filter_by_keywords
    @users = @users.by_keywords(params[:keywords]) if params[:keywords].present?
  end

  def filter_by_admin
    params[:admin] ||= 'Include'
    @users = case params[:admin]
             when 'Exclude'
               @users.where(admin: [nil, false])
             when 'Only'
               @users.where(admin: true)
             else
               @users
    end
  end

end
