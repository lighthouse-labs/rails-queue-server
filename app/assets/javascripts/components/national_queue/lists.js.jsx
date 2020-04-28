window.NationalQueue = window.NationalQueue || {};
const useContext = React.useContext;
const useState = React.useState;

window.NationalQueue.Lists = ({user}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const [adminQueue, setAdminQueue] = useState(false);
  const {queueUpdates, queueChannel} = useContext(queueContext);
  const {error, myOpenTasks, allOpenTasks, inProgress, pendingEvaluations} = window.NationalQueue.useTasks(queueUpdates, user)

  return (
    <React.Fragment>
      {error && <div class="alert alert-danger"><strong>{error}</strong></div>}
      <div className="queue-by-location">
        <div className="queue-column queue-top">
          <div className="queue-row">
            <h2 className="queue-title" >{`the ${adminQueue ? 'admin ' : ''}queue`} {queueChannel.connected || <i className="fas fa-spinner text-primary queue-loader"></i>}</h2>
            {user.admin &&
              <label className="switch">
                <input type="checkbox" value={adminQueue} onClick={e => setAdminQueue(!adminQueue)}/>
                <span className="slider round"></span>
              </label>
            }
          </div>
          <div className="queue-column mb-3">
            <NationalQueue.OpenRequestsList tasks={adminQueue ? allOpenTasks() : myOpenTasks()} admin={adminQueue} />
          </div>
        </div>
        <div className="queue-row queue-bottom">
          <div className="queue-column left">
            <NationalQueue.InProgressList tasks={inProgress()} />
            <NationalQueue.PendingEvaluationsList tasks={pendingEvaluations()} />
            <NationalQueue.InterviewStatusList user={user} />
          </div>
          <div className="queue-column right">
            <NationalQueue.StudentsList user={user} />
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
