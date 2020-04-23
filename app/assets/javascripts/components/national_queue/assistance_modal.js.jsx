window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useContext = React.useContext;

window.NationalQueue.AssistanceModal = ({request, student, hide}) => {
  const queueContext =  window.NationalQueue.QueueContext;
  const queueSocket = useContext(queueContext);
  const [formInfo, setFormInfo] = useState({
    disabled: false,
    values: {
      notes: '',
      rating: '',
      notify: false
    }
  });

  const close = () => {
    hide();
  }

  const setNotes = (e) => {
    const notes = e.target.value;
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          ...currentInputs.values,
          notes
        }
      }
    ));
  }

  const setRating = (e) => {
    const rating = e.target.value;
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          ...currentInputs.values,
          rating
        }
      }
    ));
  }

  const setNotify = (e) => {
    const notify = e.target.value;
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          ...currentInputs.values,
          notify
        }
      }
    ));
  }

  const ratingIsValid = (rating) => {
    return rating !== '';
  }

  const notesIsValid = (notes) => {
    return notes.trim() !== '';
  }

  const formIsValid = () => {
    return notesIsValid(formInfo.values.notes) && ratingIsValid(formInfo.values.rating);
  }

  const handleEndAssistance = () => {
    const notes      = formInfo.values.notes;
    const rating     = formInfo.values.rating;
    const notify     = formInfo.values.notify;

    if (!formIsValid()) {
      return;
    }

    if (request) {
      endAssistance(request, notes, notify, rating);
    } else {
      providedAssistance(student, notes, rating, notify);
    }
  }

  const endAssistance = (request, notes, notify, rating) => {
    setFormInfo(current => ({...current, disabled: true}));
    queueSocket.finishAssistance(request, notes, notify, rating);
  }

  const providedAssistance = (student, notes, rating, notify) => {
    setFormInfo(current => ({...current, disabled: true}));
    const params = {
      student_id: student.id,
      notes: notes,
      rating: rating,
      notify: notify ? true : null
    }
    $.post('/queue/provided_assistance.json', params, 'json')
      .done((data) => {
        close();
      })
      .fail((xhr, data, txt) => {
        let error = xhr.statusText;
        if (xhr.responseJSON) {
          error = xhr.responseJSON.error;
        }
        alert('Could not complete action: ' + error);
      })
      .always(() => {
        setFormInfo(current => ({...current, disabled: false}));
      });
  }

  const renderReason = (assistanceRequest) => {
    if (assistanceRequest.reason) {
      return (
        <div className="form-group">
          <b>Original reason:</b>
          {assistanceRequest.reason}
        </div>
      );
    }
  }

  return (
    <React.Fragment>
      <div className="modal-backdrop fade show"></div>
      <div className="modal fade show" style={{display: 'block'}}>
        <div className="modal-dialog">
          <div className="modal-content">
            <div className="modal-header">
              <h4 className="modal-title">Log Assistance</h4>
              <button type="button" className="close" onClick={close}>
                <span aria-hidden="true">&times;</span>
                <span className="sr-only">Close</span>
              </button>
            </div>
            <div className="modal-body">

              { request && renderReason(request) }

              <fieldset disabled={formInfo.disabled}>
                <div className={formInfo.notesValid ? "form-group" : "form-group has-error"}>
                  <label>Notes</label>
                  <textarea
                    onChange={setNotes}
                    className={`form-control ${notesIsValid(formInfo.values.notes) ? 'is_valid' : 'is_invalid'}`}
                    placeholder="How did the assistance go?"
                    value={formInfo.values.notes}>
                  </textarea>
                </div>

                <div className={formInfo.ratingValid ? "form-group" : "form-group has-error"}>
                  <label>Rating</label>
                  <select
                    onChange={setRating}
                    className={`form-control ${ratingIsValid(formInfo.values.rating) ? 'is_valid' : 'is_invalid'}`}
                    value={formInfo.values.rating}
                    required={true}>
                      <option value=''>Please Select</option>
                      <option value="1">L1 | Struggling</option>
                      <option value="2">L2 | Slightly behind</option>
                      <option value="3">L3 | On track</option>
                      <option value="4">L4 | Excellent (Needs stretch)</option>
                  </select>
                </div>
                <div className="form-group">
                  <label className="checkbox">
                    <span className="icons">
                      <span className="first-icon fui-checkbox-unchecked"></span>
                      <span className="second-icon fui-checkbox-checked"></span>
                    </span>
                    <input className="notify-checkbox" type="checkbox" onChange={setNotify} value={formInfo.values.notify} /> Notify Education Team about this
                  </label>
                </div>
              </fieldset>
            </div>
            <div className="modal-footer">
              <button type="button" className="btn btn-default" onClick={close} disabled={formInfo.disabled}>Cancel</button>
              <button type="button" className="btn btn-primary" onClick={handleEndAssistance} disabled={formInfo.disabled}>End Assistance</button>
            </div>
          </div>
        </div>
      </div>
    </React.Fragment>
  )
}
