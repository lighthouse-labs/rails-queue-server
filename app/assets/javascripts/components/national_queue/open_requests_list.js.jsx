window.Queue = window.Queue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.OpenRequestsList = ({tasks, admin, open, setOpen, user}) => {
  
  const renderRequest = (task) => {
    const request = task.taskObject;
    return <NationalQueue.PendingAssistanceRequest key={`request-${request.id}`} teachers={admin && task.teachers} request={request} />
  }

  const renderRequests = () => {
    return tasks.map(renderRequest);
  }

  const toggleOpen = () => {
    return open ? setOpen(false) : setOpen(true)
  }

  const offDutyWarning = () => {
    return  <div class="alert alert-danger"><strong>You must be on duty to be assigned a queue! <br></br> (will need to refresh to remove this message, sorry!)</strong></div>
  }

  return (
    <NationalQueue.ListGroup open={open} toggleOpen={toggleOpen} count={tasks.length} title="Open Requests">
      {user.onDuty || admin ? renderRequests() : offDutyWarning()}
    </NationalQueue.ListGroup>
  )
}
