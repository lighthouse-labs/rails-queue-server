class Admin::QueueStatsController < Admin::BaseController

  def index
    @data = QueueStats.new(params).run
  end

end
