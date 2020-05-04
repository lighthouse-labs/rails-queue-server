window.NationalQueue = window.NationalQueue || {};
const useContext = React.useContext;
const useState = React.useState;
const useEffect = React.useEffect;

window.NationalQueue.Lists = ({user}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const [userQueue, setUserQueue] = useState(null);
  const {queueUpdates, teacherUpdates, queueChannel, toggleDuty, refresh} = useContext(queueContext);
  const {error: teachersError, currentUser, teachers, teacherOnDuty} = window.NationalQueue.useTeachers(teacherUpdates, user);
  const {error, myOpenTasks, allOpenTasks, inProgress, pendingEvaluations} = window.NationalQueue.useTasks(queueUpdates, user, refresh)

  useEffect(() => {
    if (userQueue && userQueue.id && !teacherOnDuty(userQueue)) {
      setUserQueue('admin');
    }
  }, [teachers]);

  const handleToggleDuty = () => {
    toggleDuty(userQueue || currentUser);
  }

  const openTasks =  userQueue === 'admin' ? allOpenTasks() : myOpenTasks(userQueue);
  
  return (
    <React.Fragment>
      {error && <div class="alert alert-danger"><strong>{error}</strong></div>}
      <div className="queue-by-location">
        <NationalQueue.QueueMenu user={currentUser} toggleDuty={handleToggleDuty} userQueue={userQueue} setUserQueue={setUserQueue} connected={queueChannel.connected} />
        <div className="queue-column queue-top mt-3 ">
          {userQueue && <NationalQueue.QueueSelector teachers={teachers} userQueue={userQueue} setUserQueue={setUserQueue} />}
          <NationalQueue.UserStats user={currentUser} />
          <NationalQueue.OpenRequestsList tasks={openTasks} admin={userQueue} user={currentUser} />
        </div>
        <div className="queue-row queue-bottom ">
          <div className="queue-column left">
            <NationalQueue.InProgressList tasks={inProgress()} />
            <NationalQueue.PendingEvaluationsList tasks={pendingEvaluations()} />
            <NationalQueue.InterviewStatusList user={currentUser} updates={queueUpdates} />
          </div>
          <div className="queue-column right">
            <NationalQueue.StudentsList user={currentUser} updates={queueUpdates} />
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
