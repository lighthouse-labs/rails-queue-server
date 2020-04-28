window.Queue = window.Queue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.OpenRequestsList = ({tasks, admin, open, setOpen}) => {
  
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

  return (
    <NationalQueue.ListGroup open={open} toggleOpen={toggleOpen} count={tasks.length} title="Open Requests">
      {renderRequests()}
    </NationalQueue.ListGroup>
  )
}
