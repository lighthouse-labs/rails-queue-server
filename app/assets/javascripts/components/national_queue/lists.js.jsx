window.NationalQueue = window.NationalQueue || {};
const useContext = React.useContext;

window.NationalQueue.Lists = ({user}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const {queueUpdates} = useContext(queueContext);
  const {openTasks, inProgress, pendingEvaluations} = window.NationalQueue.useTasks(queueUpdates, user)

  return (
    <div className="queue-by-location">
      <div className="queue-column queue-top">
        <h2 className="queue-title" >the queue</h2>
        <div className="queue-column mb-3">
          <NationalQueue.OpenRequestsList tasks={openTasks()} />
        </div>
      </div>
      <div className="queue-row queue-bottom">
        <div className="queue-column left">
          <NationalQueue.InProgressList tasks={inProgress()} />
          <NationalQueue.PendingEvaluationsList tasks={pendingEvaluations()} />
          <NationalQueue.InterviewStatusList user={user} />
        </div>
        <div className="queue-column">
          <NationalQueue.StudentsList user={user} />
        </div>
      </div>
    </div>
  );
}
