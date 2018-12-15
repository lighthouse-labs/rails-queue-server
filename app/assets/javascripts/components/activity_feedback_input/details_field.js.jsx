window.ActivityFeedbackInput || (window.ActivityFeedbackInput = {});

window.ActivityFeedbackInput.DetailsField = class DetailsField extends React.Component {

  propTypes: {
    onChange: PropTypes.func.isRequired,
    detail:   PropTypes.string,
    saving:   PropTypes.bool
  }

  constructor(props) {
    super(props);
    // have to use state here due to the controlled/uncontrolled situation with textareas
    // https://stackoverflow.com/questions/30730369/reactjs-component-not-rendering-textarea-with-state-variable
    this.state = { detail: this.props.detail };
  }

  _onBlur = (evt) => {
    if (evt.target.value !== this.props.detail)
      this.props.onChange(evt.target.value);
  }

  _onChange = (evt) => {
    this.setState({ detail: evt.target.value });
  }

  // Have to copy to state b/c I don't know a better way to deal with this
  // https://stackoverflow.com/questions/30730369/reactjs-component-not-rendering-textarea-with-state-variable
  componentWillReceiveProps(newProps) {
    this.setState({ detail: newProps.detail });
  }

  render() {
    const saving = this.props.saving;
    const placeholder = "Please give us some written insight into your feedback";

    return(
      <div className={`mb-3 can-load ${saving ? 'loading' : ''}`}>
        <div className="d-flex justify-content-center">
          <textarea onBlur={this._onBlur}
                    onChange={this._onChange}
                    className="form-control d-inline-flex rating-label"
                    value={this.state.detail}
                    placeholder={placeholder} />
        </div>
      </div>
    );
  }
}
