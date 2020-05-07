window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;
const useState = React.useState;
const useContext = React.useContext;

window.NationalQueue.PendingAssistanceRequest = ({request, teachers, admin}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const queueSocket = useContext(queueContext);
  const [disabled, setDisabled] = useState(false);

  const handleCancelAssistance = () => {
    // TODO: use more js-centric confirm vs browser confirm
    if (confirm("Are you sure you want to cancel this Request?")) {
      setDisabled(true);
      queueSocket.cancelAssistanceRequest(request);
    }
  }

  const handleStartAssisting = () => {
    setDisabled(true);
    queueSocket.startAssisting(request);
  }

  const actionButtons = () => {
    const buttons = [null];
    buttons.push(<button key="remove" className="btn btn-sm btn-light btn-hover-danger" onClick={handleCancelAssistance} disabled={disabled}>Remove</button>)
    if (!admin) {
      buttons.push(<button key="start" className="btn btn-sm btn-secondary btn-main" onClick={handleStartAssisting} disabled={disabled}>Start Assisting</button>)
    }
    return buttons;
  }

  const renderActions = () => {
    return(
      <div className="actions float-right">
        { App.ReactUtils.joinElements(actionButtons(), null) }
      </div>
    );
  }

  const renderAssignees = () => {
    if (teachers) {
      return (
        <div className="blurb">
          <strong> Assigned to: &nbsp;</strong>
          {teachers.map((teacher, i) => <span key={i}>{teacher.firstName} {teacher.lastName}{teachers.length > i + 1 && ', '}</span>)}
        </div>
      )
    }
  }

  const student = request.requestor;
  return (
    <NationalQueue.QueueItem type='Request' disabled={disabled}>
      <NationalQueue.StudentInfo  student={student}
                          showDetails={true}
                          when={request.startAt}
                          activity={request.activity} />

      <div className="blurb">
        {App.ReactUtils.renderActivityDetails(request.activity)}
        {App.ReactUtils.renderQuote(request.reason)}
        {renderAssignees()}
      </div>
      {renderActions()}
    </NationalQueue.QueueItem>
  )
}
