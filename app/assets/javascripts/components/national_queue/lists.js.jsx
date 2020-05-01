window.NationalQueue = window.NationalQueue || {};
const useContext = React.useContext;
const useState = React.useState;

window.NationalQueue.Lists = ({user}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const [adminQueue, setAdminQueue] = useState(false);
  const [openRows, setOpenRows] = useState({top: true, bottom: 'in-progress', students: true});
  const {queueUpdates, queueChannel} = useContext(queueContext);
  const {error, myOpenTasks, allOpenTasks, inProgress, pendingEvaluations} = window.NationalQueue.useTasks(queueUpdates, user)

  const openRow = (position, number = 1, force) => {
    return ((openRows[position] && number > 0) || force) ? 'open' : '';
  }

  const openTasks =  adminQueue ? allOpenTasks() : myOpenTasks();
  return (
    <React.Fragment>
      {error && <div class="alert alert-danger"><strong>{error}</strong></div>}
      <div className="queue-by-location">
        <div className="queue-header">
          <h2 className="queue-title" >{`the ${adminQueue ? 'admin ' : ''}queue`} {queueChannel.connected || <i className="fas fa-spinner text-primary queue-loader"></i>}</h2>
          {user.admin &&
            <label className="switch">
              <input type="checkbox" value={adminQueue} onClick={e => setAdminQueue(!adminQueue)}/>
              <span 
                className="slider round"
                data-toggle='tooltip' 
                data-placement='bottom' 
                title={`Toggle Admin Queue`}
                data-original-title={`Toggle Admin Queue`}
                ref={(ref) => $(ref).tooltip()}
              ></span>
            </label>
          }
        </div>
        <div className={"queue-column queue-top mb-3 " + openRow('top', openTasks.length, !user.onDuty && !adminQueue)}>
          <NationalQueue.OpenRequestsList open={openRows.top} setOpen={(open) => setOpenRows({...openRows, top: open})} tasks={openTasks} admin={adminQueue} user={user} />
        </div>
        <div className={"queue-row queue-bottom " + (openRow('bottom') || openRow('students'))}>
          <div className="queue-column left">
            <NationalQueue.InProgressList open={openRows.bottom} setOpen={(open) => setOpenRows({...openRows, bottom: open})} tasks={inProgress()} />
            <NationalQueue.PendingEvaluationsList open={openRows.bottom} setOpen={(open) => setOpenRows({...openRows, bottom: open})} tasks={pendingEvaluations()} />
            <NationalQueue.InterviewStatusList open={openRows.bottom} setOpen={(open) => setOpenRows({...openRows, bottom: open})} user={user} updates={queueUpdates} />
          </div>
          <div className="queue-column right">
            <NationalQueue.StudentsList open={openRows.students} setOpen={(open) => setOpenRows({...openRows, students: open})} user={user} updates={queueUpdates} />
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
