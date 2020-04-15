window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.App = ({user}) => {

  useEffect(() => {
    window.current_user = user || window.current_user;
  }, []);

  return (
    <div className={`queue-container`}>
        <NationalQueue.Lists key={`location-${location.id}`} user={user} />
    </div>
  );
}

