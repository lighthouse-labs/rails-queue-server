window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;

window.NationalQueue.RequestModal = ({assistance}) => {
  const [settings, setSettings] = useState({
    notesValid: null,
    ratingValid: null,
    disabled: false
  });

  // open = () => {
  //   $(this.refs.modal).modal();
  // }

  // close = () => {
  //   $(this.refs.modal).modal('hide');
  // }

  // setNotesError = () => {
  //   this.setState({ notesValid: this.notesIsValid() });
  // }

  // setRatingError = () => {
  //   this.setState({ ratingValid: this.ratingIsValid() });
  // }

  // ratingIsValid = () => {
  //   const rating = this.refs.rating.value;
  //   return rating !== '';
  // }

  // notesIsValid = () => {
  //   const notes = this.refs.notes.value;
  //   return notes.trim() !== '';
  // }

  // formIsValid = () => {
  //   return this.notesIsValid() && this.ratingIsValid();
  // }

  // handleEndAssistance = () => {
  //   const notes      = this.refs.notes.value;
  //   const rating     = this.refs.rating.value;
  //   const notify     = this.refs.notify.checked;

  //   if(!this.formIsValid()){
  //     this.setNotesError();
  //     this.setRatingError();
  //     return;
  //   }

  //   if (this.props.assistance) {
  //     this.endAssistance(this.props.assistance, notes, rating, notify);
  //   } else {
  //     this.providedAssistance(this.props.student, notes, rating, notify);
  //   }
  // }

  // endAssistance(assistance, notes, rating, notify) {
  //   this.postAndClose('/queue/end_assistance.json', {
  //     assistance_id: assistance.id,
  //     notes: notes,
  //     rating: rating,
  //     notify: notify ? true : null
  //   });
  // }

  // providedAssistance(student, notes, rating, notify) {
  //   this.postAndClose('/queue/provided_assistance.json', {
  //     student_id: student.id,
  //     notes: notes,
  //     rating: rating,
  //     notify: notify ? true : null
  //   });
  // }

  // postAndClose(url, params) {
  //   this.setState({ disabled: true });
  //   $.post(url, params, 'json')
  //     .done((data) => {
  //       this.close();
  //     })
  //     .fail((xhr, data, txt) => {
  //       let error = xhr.statusText;
  //       if (xhr.responseJSON) {
  //         error = xhr.responseJSON.error;
  //       }
  //       alert('Could not complete action: ' + error);
  //     })
  //     .always(() => {
  //       this.setState({ disabled: false });
  //     });
  // }

  // renderReason(assistanceRequest) {
  //   if(assistanceRequest.reason) {
  //     return (
  //       <div className="form-group">
  //         <b>Original reason:</b>
  //         {assistanceRequest.reason}
  //       </div>
  //     );
  //   }
  // }

  // render() {
  //   const assistance = this.props.assistance;
  //   let assistanceRequest;

  //   if(assistance)
  //     assistanceRequest = assistance.assistanceRequest;

  //   const disabled = this.state.disabled;

  //   let notesFieldClass = '';
  //   if (this.state.notesValid === true) {
  //     notesFieldClass = 'is-valid';
  //   } else if (this.state.notesValid === false) {
  //     notesFieldClass = 'is-invalid';
  //   }

  //   let ratingFieldClass = '';
  //   if (this.state.ratingValid === true) {
  //     ratingFieldClass = 'is-valid';
  //   } else if (this.state.ratingValid === false) {
  //     ratingFieldClass = 'is-invalid';
  //   }

  //   return (
  //     <div className="modal fade" ref="modal">
  //       <div className="modal-dialog">
  //         <div className="modal-content">
  //           <div className="modal-header">
  //             <h4 className="modal-title">Log Assistance</h4>
  //             <button type="button" className="close" onClick={this.close}>
  //               <span aria-hidden="true">&times;</span>
  //               <span className="sr-only">Close</span>
  //             </button>
  //           </div>
  //           <div className="modal-body">

  //             { assistanceRequest && this.renderReason(assistanceRequest) }

  //             <fieldset disabled={disabled}>
  //               <div className={this.state.notesValid ? "form-group" : "form-group has-error"}>
  //                 <label>Notes</label>
  //                 <textarea
  //                   onChange={this.setNotesError}
  //                   className={`form-control ${notesFieldClass}`}
  //                   placeholder="How did the assistance go?"
  //                   ref="notes">
  //                 </textarea>
  //               </div>

  //               <div className={this.state.ratingValid ? "form-group" : "form-group has-error"}>
  //                 <label>Rating</label>
  //                 <select
  //                   onChange={this.setRatingError}
  //                   className={`form-control ${ratingFieldClass}`}
  //                   ref="rating"
  //                   required="true">
  //                     <option value=''>Please Select</option>
  //                     <option value="1">L1 | Struggling</option>
  //                     <option value="2">L2 | Slightly behind</option>
  //                     <option value="3">L3 | On track</option>
  //                     <option value="4">L4 | Excellent (Needs stretch)</option>
  //                 </select>
  //               </div>
  //               <div className="form-group">
  //                 <label className="checkbox">
  //                   <span className="icons">
  //                     <span className="first-icon fui-checkbox-unchecked"></span>
  //                     <span className="second-icon fui-checkbox-checked"></span>
  //                   </span>
  //                   <input className="notify-checkbox" type="checkbox" ref="notify" /> Notify Education Team about this
  //                 </label>
  //               </div>
  //             </fieldset>
  //           </div>
  //           <div className="modal-footer">
  //             <button type="button" className="btn btn-default" onClick={this.close} disabled={disabled}>Cancel</button>
  //             <button type="button" className="btn btn-primary" onClick={this.handleEndAssistance} disabled={disabled}>End Assistance</button>
  //           </div>
  //         </div>
  //       </div>
  //     </div>
  //   );
  // }

}