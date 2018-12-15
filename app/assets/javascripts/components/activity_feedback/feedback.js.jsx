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
    if (user.firstName.length + user.lastName.length > 15) {
      return `${user.firstName} ${user.lastName[0]}.`;
    } else {
      return `${user.firstName} ${user.lastName}`;
    }
  }


  _renderDucks(rating) {
    return [...Array(Number(rating))].map((_, i) => { return <img key={i} src="/larry-rating2.png" className="larry-rating" /> })
  }
  _renderRating(rating) {
    return rating && <div title={rating}>{ this._renderDucks(rating) }</div>;
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
            { _.truncate(feedback.detail, { length: 400 }) }
          </div>
        </div>

      </li>
    );
  }
}
