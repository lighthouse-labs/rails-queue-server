class NationalQueue::CreateFeedback

  include Interactor

  before do
    @task_id      = context.task_id
    @notes        = context.notes
    @rating       = context.rating
    @requestor    = context.requestor
  end

  def call
    puts '~~~create feedback'
    task = QueueTask.find_by(id: @task_id)
    context.fail! unless task
    assistance = task.assistance_request&.assistance
    puts @requestor.inspect
    puts task
    puts task.assistance_request
    if @requestor['uid'] == task.assistance_request&.requestor['uid']
      puts 'user allowed to provide feedback'
      context.fail! unless assistance.create_feedback(rating: @rating, notes: @notes)
      context.feedback = assistance.feedback
      context.updates ||= []
      context.updates.push({ task: task, shared: false })
    end
  end

  def rollback
    context.feedback.destroy
  end

end
