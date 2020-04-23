window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.App = ({user}) => {
  const queueSocket =  window.NationalQueue.useQueueSocket();

  useEffect(() => {
    window.current_user = user || window.current_user;
  }, []);

  return (
    <div className={`queue-container`}>
      <NationalQueue.QueueContext.Provider value={queueSocket}>
        <NationalQueue.Lists key={`location-${location.id}`} user={user} />
      </NationalQueue.QueueContext.Provider>
    </div>
  );
}
