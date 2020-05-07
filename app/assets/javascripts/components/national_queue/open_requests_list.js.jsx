window.Queue = window.Queue || {};
const useState = React.useState;

window.NationalQueue.OpenRequestsList = ({tasks, userQueue, user}) => {

  const renderRequest = (task) => {
    const request = task.taskObject;
    return <NationalQueue.PendingAssistanceRequest key={`request-${request.id}`} teachers={userQueue === 'admin' && task.teachers} admin={userQueue} request={request} />
  }

  const renderRequests = () => {
    return tasks.map(renderRequest);
  }

  const offDutyWarning = () => {
    return  <div className="alert alert-danger"><strong>You must be on duty to be assigned a queue!</strong></div>
  }

  return (
    <NationalQueue.ListGroup icon={(user.onDuty || userQueue) ? tasks.length : '!'} title="Open Requests">
      {user.onDuty || userQueue ? renderRequests() : offDutyWarning()}
    </NationalQueue.ListGroup>
  );
}
