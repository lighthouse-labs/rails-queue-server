window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useRef = React.useRef;

window.NationalQueue.RequestModal = ({queueSocket, show, hide}) => {
  const modalRef = useRef();
  const [formInfo, setFormInfo] = useState({
    status: 'open',
    values: {
      reason: '',
      activityId: null
    }
  });

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

  const reasonIsValid = (reason) => {
    return reason !== '';
  }

  const activityIsValid = (activityId) => {
    return notes.trim() !== '';
  }

  const formIsValid = () => {
    return reasonIsValid(formInfo.values.notes) && activityIsValid(formInfo.values.rating);
  }

  const closeRequest = () => {
    // $(modalRef.current).modal('hide');
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

  const activityOptions = () => {
    const activities = [1,2,3];
    return activities.map((activity, index) => {
      return <option key={index} value="127">test activity</option>
    })
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
              <button className="close" type='button' data-dismiss='modal'>
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
                  <textarea value={formInfo.values.reason} onChange={setReason} name="reason" placeholder='What do you need assistance with?'class='form-control' />
                </div>
                <label>
                  Activity
                </label>
                <div className="form-group" >
                  <select value={formInfo.values.activity_id} onChange={setActivityId} name="activity_id" className='form-control'>
                    <option value="" disabled>Which activity?</option>
                    {activityOptions()}
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
  );
}