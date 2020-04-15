window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;
const useState = React.useState;


window.NationalQueue.PendingAssistanceRequest = ({request}) => {
  const [disabled, setDisabled] = useState(false);

  const handleCancelAssistance = () => {
    // TODO: use more js-centric confirm vs browser confirm
    if(confirm("Are you sure you want to cancel this Request?")) {
      setDisabled(true);
      App.NationalQueue.cancelAssistanceRequest(props.request);
      ga('send', 'event', 'cancel-assistance', 'click');
    }
  }

  const handleStartAssisting = () => {
    setDisabled(true);
    App.NationalQueue.startAssisting(props.request);
    ga('send', 'event', 'start-assistance', 'click');
  }

  const actionButtons = () => {
    const buttons = [null];
    buttons.push(<button key="remove" className="btn btn-sm btn-light btn-hover-danger" onClick={handleCancelAssistance} disabled={disabled}>Remove</button>)
    buttons.push(<button key="start" className="btn btn-sm btn-secondary btn-main" onClick={handleStartAssisting} disabled={disabled}>Start Assisting</button>)
    return buttons;
  }

  const renderActions = () => {
    return(
      <div className="actions float-right">
        { App.ReactUtils.joinElements(actionButtons(), null) }
      </div>
    );
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
      </div>
      {renderActions()}
    </NationalQueue.QueueItem>
  )
}

