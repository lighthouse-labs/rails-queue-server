window.Queue = window.Queue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.OpenRequestsList = ({tasks, admin}) => {
  
  const renderRequest = (task) => {
    const request = task.taskObject;
    return <NationalQueue.PendingAssistanceRequest key={`request-${request.id}`} teachers={admin && task.teachers} request={request} />
  }

  const renderRequests = () => {
    return tasks.map(renderRequest);
  }

  return (
    <NationalQueue.ListGroup count={tasks.length} title="Open Requests">
      {renderRequests()}
    </NationalQueue.ListGroup>
  )
}
