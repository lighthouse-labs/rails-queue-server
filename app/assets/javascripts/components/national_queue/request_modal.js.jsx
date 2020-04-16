window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useRef = React.useRef;

window.NationalQueue.RequestModal = ({assistance, student}) => {
  const modalRef = useRef();
  const [formInfo, setFormInfo] = useState({
    disabled: false,
    values: {
      notes: '',
      rating: '',
      notify: false
    }
  });

  const close = () => {
    $(modalRef.current).modal('hide');
  }

  const setNotes = (e) => {
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          ...currentInputs.values,
          notes: e.target.value
        }
      }
    ));
  }

  const setRating = (e) => {
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          ...currentInputs.values,
          rating: e.target.value
        }
      }
    ));
  }

  const setNotify = (e) => {
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        values: {
          ...currentInputs.values,
          notify: e.target.value
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

    if(!formIsValid()){
      return;
    }

    if (assistance) {
      endAssistance(assistance, notes, rating, notify);
    } else {
      providedAssistance(student, notes, rating, notify);
    }
  }

  const endAssistance = (assistance, notes, rating, notify) => {
    postAndClose('/queue/end_assistance.json', {
      assistance_id: assistance.id,
      notes: notes,
      rating: rating,
      notify: notify ? true : null
    });
  }

  const providedAssistance = (student, notes, rating, notify) => {
    postAndClose('/queue/provided_assistance.json', {
      student_id: student.id,
      notes: notes,
      rating: rating,
      notify: notify ? true : null
    });
  }

  const postAndClose = (url, params) => {
    setFormInfo((currentInputs) => (
      {
        ...currentInputs,
        disabled: true
      }
    ));
    $.post(url, params, 'json')
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
        setFormInfo((currentInputs) => (
          {
            ...currentInputs,
            disabled: false
          }
        ));
      });
  }

  const renderReason = (assistanceRequest) => {
    if(assistanceRequest.reason) {
      return (
        <div className="form-group">
          <b>Original reason:</b>
          {assistanceRequest.reason}
        </div>
      );
    }
  }

  let assistanceRequest = assistance && assistance.assistanceRequest

  return (
    <div className="modal fade" ref={modalRef}>
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

            { assistanceRequest && renderReason(assistanceRequest) }

            <fieldset disabled={formInfo.disabled}>
              <div className={formInfo.notesValid ? "form-group" : "form-group has-error"}>
                <label>Notes</label>
                <textarea
                  onChange={setNotes}
                  className={`form-control ${notesIsValid(fromInfo.notes) ? 'is_valid' : 'is_invalid'}`}
                  placeholder="How did the assistance go?"
                  value={inputs.notes}>
                </textarea>
              </div>

              <div className={formInfo.ratingValid ? "form-group" : "form-group has-error"}>
                <label>Rating</label>
                <select
                  onChange={setRating}
                  className={`form-control ${ratingIsValid(fromInfo.rating) ? 'is_valid' : 'is_invalid'}`}
                  value={formInput.values.rating}
                  required="true">
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
                  <input className="notify-checkbox" type="checkbox" onChange={setNotify} value={formInput.values.notify} /> Notify Education Team about this
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
  );

}