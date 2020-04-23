window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useContext = React.useContext;

window.NationalQueue.Assistance = ({task}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const queueSocket = useContext(queueContext);
  const [disabled, setDisabled] = useState(false);
  const [showModal, setShowModal] = useState(false);

  const handleCancelAssisting = () => {
    setDisabled(true);
    queueSocket.cancelAssistance(task.taskObject);
  }

  const handleEndAssisting = () => {
    openModal();
  }

  const openModal = () => {
    setShowModal(true);
  }

  const actionButtons = () => {
    const buttons = [null];
    if (window.current_user.id === task.teacher.id) {
      task.taskObject.conferenceLink && buttons.push(
        <a key="conference" className="btn btn-sm btn-primary btn-hover-danger" href={task.taskObject.conferenceLink} target="_blank" disabled={disabled}>
          <i className="fa fa-fw fa-video"></i>
          &nbsp;Google Hangout
        </a>
      );
      buttons.push(<button key="cancel" className="btn btn-sm btn-light btn-hover-danger" onClick={handleCancelAssisting} disabled={disabled}>Cancel</button>);
      buttons.push(<button key="finish" className="btn btn-sm btn-secondary btn-main"onClick={handleEndAssisting} disabled={disabled}>Finish</button>);
    }
    return buttons;
  }

  const renderActions = () => {
    return (
      <div className="actions float-right">
        { App.ReactUtils.joinElements(actionButtons(), null) }
      </div>
    )
  }

  const request = task.taskObject;
  const student = task.taskObject.requestor;
  const assistor = task.teacher;

  return (
    <NationalQueue.QueueItem type='Assistance' disabled={disabled}>

      <NationalQueue.StudentInfo  student={student}
                          showDetails={true}
                          when={request.startAt} />

      <NationalQueue.TeacherInfo teacher={assistor} when={request.startAt} />

      <div className="blurb">
        {App.ReactUtils.renderActivityDetails(request.activity)}
        {App.ReactUtils.renderQuote(request.reason)}
      </div>
      {renderActions()}

      {showModal && <NationalQueue.AssistanceModal request={request} hide={() => {setShowModal(false)}} />}
    </NationalQueue.QueueItem>
  )
}
