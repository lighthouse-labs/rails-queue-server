window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useRef = React.useRef;
const useEffect = React.useEffect;

const requestState = (update) => {
  let state = {};
  update = update && update.object;
  if (!update || update.state === 'closed'){
    state.status = 'none';
  } else if (update.state === 'in_progress') {
    state.status = 'in-progress';
    state.assistorName = update.assistor.fullName
    state.conferenceLink = update.conferenceLink
  } else {
    state.status = 'waiting'
    state.position = update.positionInQueue
  }
  return state;
}

const buttonInfo = (requestState) => {
  if (requestState.status === 'in-progress') {
    return {
      style: 'btn-outline-warning',
      text: `${requestState.assistorName} assisting`,
      title: 'Cancel Assistance Request'
    }      
  } else if (requestState.status === 'waiting') {
    return {
      style: 'btn-outline-warning',
      text: `No. ${requestState.position} in Request Queue`,
      title: 'Cancel Assistance Request'
    }      
  } else {
    return {
      style: 'btn-primary',
      text: 'Request Assistance',
      title: 'Request Assistance'
    }
  }
}

window.NationalQueue.AssistanceButton = () => {
  const useQueueSocket =  window.NationalQueue.useQueueSocket;
  const queueSocket = useQueueSocket();
  const requestButton = useRef();
  const conferenceButton = useRef();
  const [requestModal, setRequestModal] = useState({
    render: false,
    show: false
  });

  const currentRequestState = requestState(queueSocket.requestUpdates.slice(-1)[0]);

  useEffect(() => {
    $(requestButton.current).tooltip();
    $(conferenceButton.current).tooltip();
    $(requestButton.current).tooltip('hide');
    $(conferenceButton.current).tooltip('hide');
  }, [currentRequestState, requestButton, conferenceButton]);

  const showAssistanceModal =  (e) => {
    setRequestModal({
      render: true,
      show: true
    });
  }

  const hideAssistanceModal = () => {
    setRequestModal({
      render: true,
      show: false
    });
  }

  const cancelAssistance = (e) => {
    if (confirm("Are you sure you want to cancel this Request?")) {
      queueSocket.cancelAssistanceRequest();
    }
  }

  const handleAssistanceButton = (e) => {
    e.preventDefault();
    e.stopPropagation()
    if (currentRequestState.status === 'waiting') {
      cancelAssistance();
    } else if (currentRequestState.status === 'in-progress') {
      // future option for student to finish in progress AR
      cancelAssistance();
    } else {
      showAssistanceModal()
    }
  }

  const button = buttonInfo(currentRequestState);
  return (
    <li id="assistance-request-module">
      <span id="assistance-request-actions">
        <a 
          className={`navbar-btn btn btn-outline-primary ${!(currentRequestState.conferenceLink) && 'd-none'}`} 
          id="assistance-request-conference" 
          href={currentRequestState.conferenceLink} 
          target="_blank" 
          data-toggle='tooltip' 
          data-placement='bottom' 
          title={`Google Hangout with ${currentRequestState.assistorName}`}
          data-original-title={`Google Hangout with ${currentRequestState.assistorName}`}
          ref={conferenceButton}
        >
          <i className="fa fa-fw fa-video"></i>
        </a>
        <button 
          className={`navbar-btn btn ${button.style}`}
          data-toggle='tooltip' 
          data-placement='bottom'
          onClick={handleAssistanceButton}
          data-original-title={button.title}
          title={button.title}
          ref={requestButton}
          disabled={!queueSocket.queueChannel.connected}
        >
          {queueSocket.queueChannel.connected ? button.text : <i className="fas fa-spinner queue-loader"></i>}
        </button>
      </span>

      {
        requestModal.render && <NationalQueue.RequestModal queueSocket={queueSocket} show={requestModal.show} hide={hideAssistanceModal} />
      }

    </li>
  )
}
