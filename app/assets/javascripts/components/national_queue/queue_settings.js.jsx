window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useEffect = React.useEffect;

window.NationalQueue.QueueSettings = ({user}) => {
  const [queueSettings, setQueueSettings] = useState({});
  const [status, setStatus] = useState({});

  useEffect(() => {
    setStatus({loading: true});
    const url = `/queue_tasks/settings`
    $.ajax({
      dataType: 'json',
      method: 'GET',
      url
    }).done(resp => {
      setQueueSettings(resp.queueSettings);
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

  return(
    <NationalQueue.ListGroup icon={icon()} title='Queue Settings'>
      <div className="national-queue-stats p-4">
        {(status.error || status.message) && <div className={`alert ${status.error ? 'alert-danger' : 'alert-success'}`}><strong>{status.error || status.message}</strong></div>}
        <h2>Queue Router Weights</h2>
        <form onSubmit={changeSettings} className="queue-weights">
          <div className="option">
            <div className="description">
              <label>Task Penalty</label>
              <small>The deduction to a mentors score for each queue task.</small>
            </div>
            <input 
              className="form-control" 
              type="number" 
              name="task_penalty" 
              onChange={e => setQueueSettings({...queueSettings, task_penalty: e.target.value})} 
              value={queueSettings.task_penalty || 0}
              min="-100" 
              max="0"
            />
          </div>
          <div className="option">
            <div className="description">
              <label>Assistance Penalty</label>
              <small>The deduction to a mentors score for each ongoing assistance.</small>
            </div>
            <input 
              className="form-control" 
              type="number" 
              name="assistance_penalty" 
              onChange={e => setQueueSettings({...queueSettings, assistance_penalty: e.target.value})} 
              value={queueSettings.assistance_penalty || 0}
              min="-100" 
              max="0"
            />
          </div>
          <div className="option">
            <div className="description">
              <label>Evaluation Penalty</label>
              <small>The deduction to a mentors score for each ongoing evaluation.</small>
            </div>
            <input 
              className="form-control" 
              type="number" 
              name="evaluation_penalty" 
              onChange={e => setQueueSettings({...queueSettings, evaluation_penalty: e.target.value})} 
              value={queueSettings.evaluation_penalty || 0}
              min="-100" 
              max="0"
            />
          </div>
          <div className="option">
            <div className="description">
              <label>Tech Interview Penalty</label>
              <small>The deduction to a mentors score for each ongoing tech interview.</small>
            </div>
            <input 
              className="form-control" 
              type="number" 
              name="tech_interview_penalty" 
              onChange={e => setQueueSettings({...queueSettings, tech_interview_penalty: e.target.value})} 
              value={queueSettings.tech_interview_penalty || 0}
              min="-100" 
              max="0"
            />
          </div>
          <div className="option">
            <div className="description">
              <label>Same Location Bonus</label>
              <small>Bonus score for a mentor being in the same location as a student.</small>
            </div>
            <input 
              className="form-control" 
              type="number" 
              name="same_location_bonus" 
              onChange={e => setQueueSettings({...queueSettings, same_location_bonus: e.target.value})} 
              value={queueSettings.same_location_bonus || 0}
              min="0" 
              max="100"
            />
          </div>
          <div className="option">
            <div className="description">
              <label>Rating Multiplier</label>
              <small>Give a higher or lower weight to how important previous positive assistances are.</small>
            </div>
            <input 
              className="form-control" 
              type="number" 
              name="rating_multiplier" 
              onChange={e => setQueueSettings({...queueSettings, rating_multiplier: e.target.value})} 
              value={queueSettings.rating_multiplier || 0}
              min="0" 
              max="100"
            />
          </div>
          <div className="option">
            <div className="description">
              <label>Desired Task Assignment</label>
              <small>The router will try to assign an assistance request to this many queues.</small>
            </div>
            <input 
              className="form-control" 
              type="number" 
              name="desired_task_assignment" 
              onChange={e => setQueueSettings({...queueSettings, desired_task_assignment: e.target.value})} 
              value={queueSettings.desired_task_assignment || 0}
              min="0" 
              max="100"
            />
          </div>
          <div className="option">
            <div className="description">
              <label>Max Queue Size</label>
              <small>The router will try to keep mentor's queue size within this limit.</small>
            </div>
            <input 
              className="form-control" 
              type="number" 
              name="max_queue_size" 
              onChange={e => setQueueSettings({...queueSettings, max_queue_size: e.target.value})} 
              value={queueSettings.max_queue_size || 0}
              min="0" 
              max="100"
            />
          </div>
          <div className="option">
            <div className="description">
            </div>
            <input className="btn btn-warning" type="submit" disabled={status.loading} />
          </div>
        </form>
      </div>
    </NationalQueue.ListGroup>
  )
}
