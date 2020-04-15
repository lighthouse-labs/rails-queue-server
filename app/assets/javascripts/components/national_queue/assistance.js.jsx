window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useRef = React.useRef;

window.NationalQueue.Assistance = ({assistance}) => {
  const [disabled, setDisabled] = useState(false);
  const requestModalRef = useRef();

  const handleCancelAssisting = () => {
    setDisabled(true);
    App.queue.cancelAssisting(assistance);
    ga('send', 'event', 'cancel-assistance', 'click');
  }

  const handleEndAssisting = () => {
    openModal();
  }

  const openModal = () => {
    requestModalRef.current.open();
  }

  const actionButtons = () => {
    const buttons = [null];
    if (window.current_user.id === assistance.assistor.id) {
      assistance.conferenceLink && buttons.push(
        <a key="conference" className="btn btn-sm btn-primary btn-hover-danger" href={assistance.conferenceLink} target="_blank" disabled={disabled}>
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
    return(
      <div className="actions float-right">
        { App.ReactUtils.joinElements(actionButtons(), null) }
      </div>
    );
  }

  const request = assistance.assistanceRequest;
  const student = assistance.assistee;
  const assistor = assistance.assistor;

  return (
    <NationalQueue.QueueItem type='Assistance' disabled={disabled}>

      <NationalQueue.StudentInfo  student={student}
                          showDetails={true}
                          when={request.startAt} />

      <NationalQueue.TeacherInfo teacher={assistor} when={assistance.startAt} />

      <div className="blurb">
        {App.ReactUtils.renderActivityDetails(request.activity)}
        {App.ReactUtils.renderQuote(assistance.assistanceRequest.reason)}
      </div>
      {renderActions()}

      <NationalQueue.RequestModal assistance={assistance} ref={requestModalRef} />
    </NationalQueue.QueueItem>
  )
}

