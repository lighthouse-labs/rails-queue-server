window.ActivityFeedbackInput || (window.ActivityFeedbackInput = {});

window.ActivityFeedbackInput.App = class App extends React.Component {

  propTypes: {
    activityId:       PropTypes.number.required,
    activityFeedback: PropTypes.object
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

  _ratingChanged = (rating) => {
    this.setState({ rating: rating, saving: true });
    this._submitFeedback({ rating: rating });
  }

  _detailChanged = (detail) => {
    this.setState({ detail: detail, saving: true });
    this._submitFeedback({ detail: detail });
  }

  _submitFeedback(data) {
    const url = `/activities/${this.props.activityId}/my_feedback`;
    $.ajax({
      url: url,
      method: 'PUT' ,
      data: data
    })
      .then((json) => {
        if (json.success) {
          this.setState({ activityFeedback: json.activityFeedback });
          window.App.activityFeedbackApp && window.App.activityFeedbackApp.reset();
        } else if (json.error) {
          alert(json.error);
        }
      })
      .always(() => this.setState({ saving: false }));
  }

  render() {
    const feedback = this.state.activityFeedback;
    const saving  = this.state.saving;
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
