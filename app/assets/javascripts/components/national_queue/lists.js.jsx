window.NationalQueue = window.NationalQueue || {};
const useContext = React.useContext;
const useState = React.useState;
const useEffect = React.useEffect;

window.NationalQueue.Lists = ({user}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const [queueState, setQueueState] = useState({
    userQueue: null,
    view: 'queue'
  });
  const {queueUpdates, teacherUpdates, queueChannel, toggleDuty, refresh} = useContext(queueContext);
  const {error: teachersError, currentUser, teachers, teacherOnDuty} = window.NationalQueue.useTeachers(teacherUpdates, user);
  const {error, myOpenTasks, allOpenTasks, inProgress, pendingEvaluations} = window.NationalQueue.useTasks(queueUpdates, user, refresh)

  useEffect(() => {
    if (queueState.userQueue && queueState.userQueue.id && !teacherOnDuty(queueState.userQueue)) {
      setQueueState((state) => ({...state, userQueue: 'admin'}));
    }
  }, [teachers]);

  const setUserQueue = (user) => {
    setQueueState((state) => ({...state, userQueue: user}));
  }

  const changeView = (view) => {
    setQueueState((state) => ({...state, view}));
  }

  const handleToggleDuty = () => {
    toggleDuty(queueState.userQueue || currentUser);
  }

  const openTasks =  queueState.userQueue === 'admin' ? allOpenTasks() : myOpenTasks(queueState.userQueue);
  
  return (
    <React.Fragment>
      {error && <div class="alert alert-danger"><strong>{error}</strong></div>}
      <div className="queue-by-location">
        <NationalQueue.QueueMenu user={currentUser} toggleDuty={handleToggleDuty} queueState={queueState} changeView={changeView} setUserQueue={setUserQueue} connected={queueChannel.connected} />
        {queueState.view === 'settings' && currentUser.superAdmin && <NationalQueue.QueueSettings user={currentUser} />}
        {queueState.view === 'queue' &&
          <React.Fragment>
            <div className="queue-column queue-top mt-3 ">
              {queueState.userQueue && <NationalQueue.QueueSelector teachers={teachers} userQueue={queueState.userQueue} setUserQueue={setUserQueue} />}
              {queueState.userQueue && queueState.userQueue !== 'admin' && <NationalQueue.UserStats user={queueState.userQueue || currentUser} />}
              <NationalQueue.OpenRequestsList tasks={openTasks} admin={queueState.userQueue} user={currentUser} />
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
          </React.Fragment>
        }
      </div>
    </React.Fragment>
  )
}
