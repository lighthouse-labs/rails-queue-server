window.ActivityFeedbackInput || (window.ActivityFeedbackInput = {});

window.ActivityFeedbackInput.App = class App extends React.Component {

  propTypes: {
    activityId:       PropTypes.number.required,
    activityFeedback: PropTypes.object,
    stealthSaving:    PropTypes.bool,   // true: dont show user you are saving
    windowKey:        PropTypes.string, // what name to save self as on window obj
    sisterWindowKey:  PropTypes.string  // name of the sister component to update
  }

  constructor(props) {
    super(props);
    let rating, detail;
    const feedback = this.props.activityFeedback;
    if (feedback) {
      rating = feedback.rating;
      detail = feedback.detail;
    }
    this.state = {
      rating: rating,
      detail: detail,
      activityFeedback: feedback
    };
  }

  componentDidMount() {
    if (this.props.windowKey) {
      window.App[this.props.windowKey] = this;
    }
  }

  componentWillUnmount() {
    if (this.props.windowKey) {
      window.App[this.props.windowKey] = undefined;
    }
  }

  _ratingChanged = (rating) => {
    this.setState({ rating: rating, saving: true });
    this._submitFeedback({ rating: rating });
  }

  _detailChanged = (detail) => {
    this.setState({ detail: detail, saving: true });
    this._submitFeedback({ detail: detail });
  }

  // External method to be called by "sister" component
  // This is because there are two copies/instances of this input component/app
  // On the activities#show page.
  // One at the bottom of page and one in the completion modal
  // They use this method to keep each other in sync.
  updateState(newState) {
    this.setState(newState);
  }

  _submitFeedback(data) {
    const url = `/activities/${this.props.activityId}/my_feedback`;
    $.ajax({
      url: url,
      method: 'PUT' ,
      data: data
    })
      .then(this._feedbackSubmitted)
      .always(() => this.setState({ saving: false }));
  }

  _feedbackSubmitted = (json) => {
    if (json.success) {
      this.setState({ activityFeedback: json.activityFeedback });
      window.App.activityFeedbackApp && window.App.activityFeedbackApp.reset();
      // updateSisterComponent
      this._updateSisterComponent(json);
    } else if (json.error) {
      alert(json.error);
    }
  }

  _updateSisterComponent(json) {
    if (this.props.sisterWindowKey && window.App[this.props.sisterWindowKey]) {
      const feedback = json.activityFeedback;

      window.App[this.props.sisterWindowKey].updateState({
        detail: feedback.detail,
        rating: feedback.rating,
        activityFeedback: feedback
      });
    }
  }

  render() {
    const feedback = this.state.activityFeedback;
    const saving  = this.state.saving && !this.props.stealthSaving;
    let message = "Let us know how we're doing";
    if (saving) {
      message = "Saving ..."
    } else if (feedback) {
      const hasDetail = _.trim(feedback.detail).length > 0;
      message = `Thank you for your ${hasDetail ? 'detailed ' : ''}feedback`;
    }

    return(
      <div className="provide-activity-feedback-app">
        <h3 className="text-center mt-4 mb-0">Did you like this activity?</h3>
        <p className="text-center">
          <small className="text-dark">{message}</small>
        </p>

        <ActivityFeedbackInput.RatingButtons onChange={this._ratingChanged} rating={this.state.rating} saving={saving} />

        { feedback && <ActivityFeedbackInput.DetailsField onChange={this._detailChanged} detail={this.state.detail} saving={saving} /> }

      </div>
    );
  }

}
