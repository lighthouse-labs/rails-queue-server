window.ActivityFeedback || (window.ActivityFeedback = {});

window.ActivityFeedback.Feedback = class Feedback extends React.Component {

  propTypes: {
    feedback: PropTypes.object.isRequired
  }

  constructor(props) {
    super(props);
    // ?
  }

  _fullName(user) {
    const fName = _.trim(user.firstName);
    const lName = _.trim(user.lastName);
    if (fName.length + lName.length > 15) {
      return `${fName} ${lName[0]}.`;
    } else {
      return `${fName} ${lName}`;
    }
  }


  _renderDucks(rating) {
    return [...Array(Number(rating))].map((_, i) => { return <i key={i} className={`fa fa-star rating rating${rating}`} /> })
  }

  _renderRating(rating) {
    return rating && <div title={rating}>{ this._renderDucks(rating) }</div>;
  }

  _renderFeedbackDetail(detail) {
    return _.truncate(detail, { length: 4000 }).split('\n').map((text, i) => {
      return <p key={i} className="mb-0">{text}</p>
    });
  }

  render() {
    const feedback = this.props.feedback;

    return(
      <li className="list-group-item">
        <img className="avatar" src={feedback.user.avatarUrl} alt='Avatar' />
        <div className="content">
          <strong>{this._fullName(feedback.user)}</strong>
          &nbsp;
          <small className="font-weight-light">
            <TimeAgo date={feedback.createdAt} live={false} />
          </small>
          { this._renderRating(feedback.rating) }
          <div title={feedback.detail}>
            { this._renderFeedbackDetail(feedback.detail) }
          </div>
        </div>

      </li>
    );
  }
}
