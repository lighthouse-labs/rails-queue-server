window.NationalQueue = window.NationalQueue || {};
const useEffect = React.useEffect;

window.NationalQueue.RequestModal = ({queueSocket, show, hide}) => {
  const [formInfo, setFormInfo] = useState({
    status: 'open',
    values: {
      reason: '',
      activityId: null
    }
  });
  const [activityOptions, setActivityOptions] = useState([]);

  useEffect(() => {
    const url = `/queue_tasks/day_activities`
    $.ajax({
      dataType: 'json',
      method: 'GET',
      url
    }).done(resp => {
      setActivityOptions(resp);
    }).always(() => {
      // setLoading(false);
    })
  }, []);

  const setReason = (e) => {
    const reason = e.target.value;
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          ...currentInputs.values,
          reason
        }
      }
    ));
  }

  const setActivityId = (e) => {
    const activityId = e.target.value;
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          ...currentInputs.values,
          activityId
        }
      }
    ));
  }

  const closeRequest = () => {
    hide();
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          reason: '',
          activityId: null
        }
      }
    ));
  }

  const requestAssistance = () => {
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        status: 'pending'
      }
    ));
    queueSocket.requestAssistance(formInfo.values.reason, formInfo.values.activityId);
    closeRequest();
  }

  const activitySelects = (activities) => {
    return activities.map((activity, index) => {
      return <option key={index} value={activity[2]}>{activity[0]}</option>
    })
  }

  const activitySelectGroups = () => {
    const options = [];
    for (let group in activityOptions) {
      options.push(
        <optgroup key={group} label={group}>
          {activitySelects(activityOptions[group])}
        </optgroup>
      )
    }
    return options;
  }

  return show && (
    <React.Fragment>
      <div className="modal-backdrop fade show"></div>
      <div className="modal fade show" style={{display: 'block'}}>
        <div className="modal-dialog" >
          <div className="modal-content" >
            <div className="modal-header" >
              <h4 className="modal-title">
                Bring in the big guns
              </h4>
              <button className="close" onClick={closeRequest} type='button' data-dismiss='modal'>
                <span  aria-hidden='true'>
                  &times;
                </span>
                <span className="sr-only">
                  Close
                </span>
              </button>
            </div>
            <form id='assistance-request-form'>
              <div className="modal-body" >
                <label> 
                  Description
                </label>
                <div className="form-group" >
                  <textarea value={formInfo.values.reason} onChange={setReason} name="reason" placeholder='What do you need assistance with?'className='form-control' />
                </div>
                <label>
                  Activity
                </label>
                <div className="form-group" >
                  <select value={formInfo.values.activity_id} onChange={setActivityId} name="activity_id" className='form-control'>
                    <option value="" disabled>Which activity?</option>
                    {activitySelectGroups()}
                  </select>
                </div>
              </div>
              <div className="modal-footer" >
                <button onClick={closeRequest}className="btn btn-outline-danger" type='button' data-dismiss='modal'>
                  Cancel
                </button>
                <button onClick={requestAssistance}className="btn btn-primary" type='button' data-dismiss='modal'>
                  Request Assistance
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
