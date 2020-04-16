class RequestQueue::SmartTaskRoute

  include Interactor

  before do
    @assistance_request = context.assistance_request
  end

  def call
    updates = []
    if @assistance_request.queue_tasks.empty?
      # start with stupid smart routing. 
      Teacher.on_duty.each do |teacher| 
        task = @assistance_request.assign_task(teacher)
        updates.push({task: task, shared: false})
      end
    else
      # later may re assign tasks
      @assistance_request.queue_tasks.each do |task|
        updates.push({task: task, shared: public_task(task)})
      end
    end
    context.updates = updates
  end

  def public_task(task)
    task.user == task.assistance_request.assistance&.assistor
  end

end
