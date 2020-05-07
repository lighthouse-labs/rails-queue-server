window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useEffect = React.useEffect;

window.NationalQueue.QueueSettings = ({user}) => {
  const [queueSettings, setQueueSettings] = useState({});
  const [status, setStatus] = useState({
    task_penalty: -2,
    assistance_penalty: -1,
    evaluation_penalty: 0,
    tech_interview_penalty: -3,
    same_location_bonus: 5,
    rating_multiplier: 1.5,
    desired_task_assignment: 5,
    max_queue_size: 10,
  });
  const descriptions = {
    task_penalty: "The deduction to a mentors score for each queue task.",
    assistance_penalty: "The deduction to a mentors score for each ongoing assistance.",
    evaluation_penalty: "The deduction to a mentors score for each ongoing evaluation.",
    tech_interview_penalty: "The deduction to a mentors score for each ongoing tech interview.",
    same_location_bonus: "Bonus score for a mentor being in the same location as a student.",
    rating_multiplier: "Give a higher or lower weight to how important previous positive assistances are.",
    desired_task_assignment: "The router will try to assign an assistance request to this many queues.",
    max_queue_size: "The router will try to keep mentor's queue size within this limit."
  }

  useEffect(() => {
    setStatus({loading: true});
    const url = `/queue_tasks/settings`
    $.ajax({
      dataType: 'json',
      method: 'GET',
      url
    }).done(resp => {
      setQueueSettings(settings => ({...settings, ...resp.queueSettings}));
      setStatus({});
    }).fail((resp) => {
      if(resp.status==500 || resp.status==0){
        setStatus({error: "Could not load the queue settings."});
      }
    });
  }, []);

  const changeSettings = (e) => {
    setStatus({loading: true});
    e.preventDefault();
    if (confirm("Are you sure you want to change the queue settings? This will affect all future Assistance Requests.")) {
      const url = `/queue_tasks/settings`
      $.ajax({
        dataType: 'json',
        method: 'PUT',
        data: {queue_settings: queueSettings},
        url
      }).done((resp) => {
        setStatus({message: "Successfully updated the settings."});
      }).fail((resp) => {
        if(resp.status==500 || resp.status==0){
          setStatus({error: resp.responseJSON.message || resp.responseText});
        }
      });
    }
  }

  const icon = () => {
    return <i className="fas fa-cogs"></i>
  }

  const snakeToTitle = (str) => {
    let words = str.split('_');
    return words = words.map((word) => {
      return word[0].toUpperCase() + word.slice(1);
    }).join(' ');
  }

  const option = (name) => {
    return (
      <div className="option">
        <div className="description">
          <label>{snakeToTitle(name)}</label>
          <small>{descriptions[name]}</small>
        </div>
        <input 
          className="form-control" 
          type="number" 
          name={name} 
          onChange={e => setQueueSettings({...queueSettings, [name]: e.target.value})} 
          value={queueSettings[name] || 0}
          min={-100}
          max={100}
        />
      </div>
    );
  }

  const options = () => {
    return Object.keys(queueSettings).map((name) => option(name));
  }

  return (
    <NationalQueue.ListGroup icon={icon()} title='Queue Settings'>
      <div className="national-queue-stats p-4">
        {(status.error || status.message) && <div className={`alert ${status.error ? 'alert-danger' : 'alert-success'}`}><strong>{status.error || status.message}</strong></div>}
        <h2>Queue Router Weights</h2>
        <form onSubmit={changeSettings} className="queue-weights">
          {options()}
          <div className="option">
            <div className="description">
            </div>
            <input className="btn btn-warning" type="submit" disabled={status.loading} />
          </div>
        </form>
      </div>
    </NationalQueue.ListGroup>
  );
}
