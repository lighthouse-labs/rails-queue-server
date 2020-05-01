window.NationalQueue = window.NationalQueue || {};
const useContext = React.useContext;
const useState = React.useState;

window.NationalQueue.Lists = ({user}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const [userQueue, setUserQueue] = useState(null);
  const {queueUpdates, teacherUpdates, queueChannel, toggleDuty, refresh} = useContext(queueContext);
  const {error: teachersError, currentUser, teachers} = window.NationalQueue.useTeachers(teacherUpdates, user);
  const {error, myOpenTasks, allOpenTasks, inProgress, pendingEvaluations} = window.NationalQueue.useTasks(queueUpdates, user, refresh)

  const handleToggleDuty = () => {
    toggleDuty(userQueue || user);
  }

  const openTasks =  userQueue === 'admin' ? allOpenTasks() : myOpenTasks(userQueue);
  
  return (
    <React.Fragment>
      {error && <div class="alert alert-danger"><strong>{error}</strong></div>}
      <div className="queue-by-location">
        <NationalQueue.QueueMenu user={user} toggleDuty={handleToggleDuty} userQueue={userQueue} setUserQueue={setUserQueue} connected={queueChannel.connected} />
        <div className="queue-column queue-top mb-3 mt-3 ">
          <NationalQueue.QueueSelector teachers={teachers} userQueue={userQueue} setUserQueue={setUserQueue} />
          <NationalQueue.OpenRequestsList tasks={openTasks} admin={userQueue} user={user} />
        </div>
        <div className="queue-row queue-bottom ">
          <div className="queue-column left">
            <NationalQueue.InProgressList tasks={inProgress()} />
            <NationalQueue.PendingEvaluationsList tasks={pendingEvaluations()} />
            <NationalQueue.InterviewStatusList user={user} updates={queueUpdates} />
          </div>
          <div className="queue-column right">
            <NationalQueue.StudentsList user={user} updates={queueUpdates} />
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
