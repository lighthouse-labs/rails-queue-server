window.NationalQueue = window.NationalQueue || {};

window.NationalQueue.AssistanceButton = ({user}) => {
  const queueContext =  window.NationalQueue.queueContext;
  const queueSocket = useContext(queueContext);

  const requestAssistance =  (e) => {
    reasonTextField = 4 //$(@).closest('form').find('textarea')
    reason = reasonTextField.val()
    activityId = 5 //$(@).closest('form').find('select').val()
    // window.App.userChannel.requestAssistance(reason, activityId)
    queueSocket.requestAssistance(user, reason, activityId);
    reasonTextField.val('')
  }
  
  const cancelAssistance = (e) => {
    if (true) { //pop up if user wants to cancel
      // window.App.userChannel.cancelAssistanceRequest()
      queueSocket.cancelAssistance(user);
    }
  }

  const handleAssistanceButton = (e) => {
    e.preventDefault();
    e.stopPropagation()
    if (user.waitingForAssistance) {
      cancelAssistance();
    } else if (user.beingAssisted) {
      //finishAssistance();
    } else {
      requestAssistance()
    }
  }


  const assistorName = () => {
    return (user.currentAssistor && user.currentAssistor.first_name) ? `${user.currentAssistor.first_name} ${user.currentAssistor.last_name}` : 'TA';
  }

  const buttonText = () => {
    if(user.beingAssisted){
      return assistorName() + ' assisting';
    }else if(user.waitingForAssistance){
      return `No. ${user.positionInQueue || 1} in Request Queue`
    }else {
      return "Request Assistance";
    }
  }

  const buttonInfo = () => {
    return {
      style: (user.waitingForAssistance || user.beingAssisted) ? 'btn-outline-warning' : 'btn-primary',
      text: buttonText(),
      title: user.beingAssisted ? 'Finish this Assistance Request' : 'Cancel Assistance Request'
    }
  }

  const button = buttonInfo();
  return (
      <li id="assistance-request-module">
        <span id="assistance-request-actions">
          <a 
            className={`navbar-btn btn btn-outline-primary ${!(user.beingAssisted && user.currentAssistanceConference) && 'd-none'}`} 
            id="assistance-request-conference" 
            href={user.currentAssistanceConference} 
            target="_blank" 
            data-toggle='tooltip' 
            data-placement='bottom' 
            title={`Google Hangout with ${assistorName()}`}
            ref={ref => $(ref).tooltip()}
          >
            <i className="fa fa-fw fa-video"></i>
          </a>
          <button 
            className={`navbar-btn btn ${button.style} cancel-request-assistance-button`}
            data-toggle='tooltip' 
            data-placement='bottom'
            onClick={handleAssistanceButton}
            title={button.title}
            ref={ref => $(ref).tooltip()}
          >
            {button.text}
          </button>
        </span>

        {/* <span id="create-assistance-request" className={((user.waiting_for_assistance || user.being_assisted) ? 'd-none' : '')}>

          <button className="btn navbar-btn btn-primary" data-toggle="modal" data-target="#assistance-request-reason-modal" onclick="ga('send', 'event', 'request-assistance', 'click', 'student-requested-assistance');">
            {buttonText()}
          </button>
        </span> */}


      </li>

  );
};