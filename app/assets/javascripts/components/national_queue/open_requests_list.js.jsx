window.Queue = window.Queue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.OpenRequestsList = ({requests}) => {
  
  const renderRequest = (request) => {
    return <NationalQueue.PendingAssistanceRequest key={`request-${request.id}`} request={request} />
  }

  const renderRequests = () => {
    return requests.map(renderRequest);
  }

  return (
    <NationalQueue.ListGroup count={requests.length} title="Open Requests">
      {renderRequests()}
    </NationalQueue.ListGroup>
  );
}
