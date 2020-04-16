window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.Lists = ({user}) => {
  const {openTasks, inProgress, pendingEvaluations} = window.NationalQueue.useTasks()


  return (
    <div className="queue-by-location">
      <div className="row">
        <div className="col-lg-11">
          <NationalQueue.OpenRequestsList requests={openTasks()} />
          <hr/>
        </div>
      </div>
      <div className="row">
        <div className="col-lg-6">
          <NationalQueue.InProgressList tasks={inProgress()} />
          <NationalQueue.PendingEvaluationsList tasks={pendingEvaluations()} />
          <NationalQueue.InterviewStatusList user={user} />
        </div>
        <div className="col-lg-5">
          <NationalQueue.StudentsList user={user} />
        </div>
      </div>
    </div>
  );
}
