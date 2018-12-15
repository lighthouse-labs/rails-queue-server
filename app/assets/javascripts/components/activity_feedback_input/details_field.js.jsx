window.ActivityFeedbackInput || (window.ActivityFeedbackInput = {});

window.ActivityFeedbackInput.DetailsField = class DetailsField extends React.Component {

  propTypes: {
    onChange: PropTypes.func.isRequired,
    detail:   PropTypes.string,
    saving:   PropTypes.bool
  }

  _onChange = (evt) => {
    if (evt.target.value !== this.props.detail)
      this.props.onChange(evt.target.value);
  }

  render() {
    const saving = this.props.saving;
    return(
      <div className={`can-load ${saving ? 'loading' : ''}`}>
        <div className="d-flex justify-content-center">
          <textarea onBlur={this._onChange} className="form-control d-inline-flex rating-label" defaultValue={this.props.detail} placeholder="Please give us some written insight into your feedback" />
        </div>
      </div>
    );
  }
}
