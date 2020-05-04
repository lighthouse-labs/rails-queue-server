window.Queue = window.Queue || {};
const useState = React.useState;

window.NationalQueue.OpenRequestsList = ({tasks, admin, user}) => {

  const renderRequest = (task) => {
    const request = task.taskObject;
    return <NationalQueue.PendingAssistanceRequest key={`request-${request.id}`} teachers={admin === 'admin' && task.teachers} request={request} />
  }

  const renderRequests = () => {
    return tasks.map(renderRequest);
  }

  const offDutyWarning = () => {
    return  <div className="alert alert-danger"><strong>You must be on duty to be assigned a queue!</strong></div>
  }

  return (
    <NationalQueue.ListGroup icon={(user.onDuty || admin) ? tasks.length : '!'} title="Open Requests">
      {user.onDuty || admin ? renderRequests() : offDutyWarning()}
    </NationalQueue.ListGroup>
  )
}
