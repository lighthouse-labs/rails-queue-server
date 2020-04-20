window.NationalQueue = window.NationalQueue || {};
const useContext = React.useContext;

window.NationalQueue.Lists = ({user}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const {queueUpdates} = useContext(queueContext);
  const {openTasks, inProgress, pendingEvaluations} = window.NationalQueue.useTasks(queueUpdates, user)

  return (
    <div className="queue-by-location">
      <div className="row">
        <div className="col-lg-11">
          <NationalQueue.OpenRequestsList tasks={openTasks()} />
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
