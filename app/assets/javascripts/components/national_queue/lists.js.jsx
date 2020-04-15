window.NationalQueue = window.NationalQueue || {};
const useTasks = window.NationalQueue.useTasks
window.NationalQueue.Lists = ({user}) => {


  return (
    <div className="queue-by-location">
      <div className="row">
        <div className="col-lg-11">
          <NationalQueue.OpenRequestsList requests={useTasks.openTasks()} />
          <hr/>
        </div>
      </div>
      <div className="row">
        <div className="col-lg-6">
          <NationalQueue.InProgressList tasks={useTasks.inProgress()} />
          <NationalQueue.PendingEvaluationsList tasks={useTasks.pendingEvaluations()} />
          <NationalQueue.InterviewStatusList user={user} />
        </div>
        <div className="col-lg-5">
          <NationalQueue.StudentsList user={user} />
        </div>
      </div>
    </div>
  );
}
