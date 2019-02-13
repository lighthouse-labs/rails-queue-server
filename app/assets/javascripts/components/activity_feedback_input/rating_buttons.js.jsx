window.ActivityFeedbackInput || (window.ActivityFeedbackInput = {});

window.ActivityFeedbackInput.RatingButtons = class RatingButtons extends React.Component {

  propTypes: {
    onChange: PropTypes.func.isRequired,
    rating:   PropTypes.number,
    saving:   PropTypes.bool
  }

  constructor(props) {
    super(props);
    this.state = {
      hovering: false
    };
    this._ratingLabels = [
      'Very Problematic',
      'Problematic',
      'Acceptable',
      'Good',
      'Great'
    ];
  }

  _onHover = (rating) => {
    this.setState({ hovering: rating });
  }

  _resetHover = (e) => {
    this.setState({ hovering: false });
  }

  _starClasses(newRating) {
    const hovering = this.state.hovering;
    const rating   = this.props.rating;

    if (hovering) {
      return(newRating <= hovering ? `rating${hovering}` : '');
    } else if (rating && newRating <= rating) {
      return `rating${rating}`;
    }
  }

  _ratingLabelFor(rating) {
    return this._ratingLabels[rating-1];
  }

  _ratingLabel() {
    if (this.state.hovering) {
      return this._ratingLabelFor(this.state.hovering);
    } else if (this.props.rating) {
      return this._ratingLabelFor(this.props.rating);
    }
  }

  _onRatingClicked = (rating, e) => {
    e.preventDefault();
    if (this.state.rating === rating) return;
    this.props.onChange(rating);
  }

  render() {
    const starType = this.state.hovering || this.props.rating ? 'fa' : 'far';
    const saving = this.props.saving;
    return(
      <div className={`can-load ${saving ? 'loading' : ''}`}>
        <div className="d-flex justify-content-center" onMouseLeave={this._resetHover}>
          <a onMouseOver={this._onHover.bind(this, 1)} className={`rating d-inline-flex p-2 mr-1 ml-1 bd-highlight ${this._starClasses(1)}`} href="#" onClick={this._onRatingClicked.bind(this, 1)}>
            <i className={`fa-star ${starType}`} />
          </a>
          <a onMouseOver={this._onHover.bind(this, 2)} className={`rating d-inline-flex p-2 mr-1 ml-1 bd-highlight ${this._starClasses(2)}`} href="#" onClick={this._onRatingClicked.bind(this, 2)}>
            <i className={`fa-star ${starType}`} />
          </a>
          <a onMouseOver={this._onHover.bind(this, 3)} className={`rating d-inline-flex p-2 mr-1 ml-1 bd-highlight ${this._starClasses(3)}`} href="#" onClick={this._onRatingClicked.bind(this, 3)}>
            <i className={`fa-star ${starType}`} />
          </a>
          <a onMouseOver={this._onHover.bind(this, 4)} className={`rating d-inline-flex p-2 mr-1 ml-1 bd-highlight ${this._starClasses(4)}`} href="#" onClick={this._onRatingClicked.bind(this, 4)}>
            <i className={`fa-star ${starType}`} />
          </a>
          <a onMouseOver={this._onHover.bind(this, 5)} className={`rating d-inline-flex p-2 mr-1 ml-1 bd-highlight ${this._starClasses(5)}`} href="#" onClick={this._onRatingClicked.bind(this, 5)}>
            <i className={`fa-star ${starType}`} />
          </a>
        </div>
        <div className="d-flex justify-content-center my-2">
          <span className="d-inline-flex rating-label">{this._ratingLabel()}</span>
        </div>
      </div>
    );
  }
}
