window.ActivityFeedback || (window.ActivityFeedback = {});

window.ActivityFeedback.Filters = class Filters extends React.Component {

  propTypes: {
    meta: PropTypes.object.isRequired,
    filterOptions: PropTypes.object.isRequired,
    triggerReload: PropTypes.func.isRequired
  }

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    $('[data-toggle="tooltip"]').tooltip();
  }

  componentDidUpdate() {
    $('[data-toggle="tooltip"]').tooltip();
  }

  _toggleRating(rating) {
    const newState = {};
    const opts = this.props.filterOptions;
    newState[rating] = !opts[rating]; // toggle boolean
    this.props.changeFilters(newState);
  }

  _toggleFeedbackRequirement = () => {
    const opts = this.props.filterOptions;
    this.props.changeFilters({ requireFeedback: !opts.requireFeedback });
  }
  _toggleCohort = () => {
    const opts = this.props.filterOptions;
    let cohort = !opts.cohort ? this.props.cohortID : false;
    this.props.changeFilters({ cohort: cohort });
  }
  _showAll = () => {
    if (this._isShowingAll()) return;
    this.props.changeFilters({
      cohort: false,
      requireFeedback: false,
      one: true,
      two: true,
      three: true,
      four: true,
      five: true
    });
  }

  _showNotableOnly = () => {
    if (this._isShowingNotableOnly()) return;
    this.props.changeFilters({
      requireFeedback: true,
      one: true,
      two: true,
      three: true,
      four: true,
      five: true
    });
  }

  _showCriticalOnly = () => {
    if (this._isShowingCriticalOnly()) return;
    this.props.changeFilters({
      requireFeedback: true,
      one: true,
      two: true,
      three: true,
      four: false,
      five: false
    });
  }

  _isShowingAll() {
    const opts = this.props.filterOptions;
    return( !opts.cohort &&
            !opts.requireFeedback &&
            opts.one &&
            opts.two &&
            opts.three &&
            opts.four &&
            opts.five)
  }

  _isShowingNotableOnly() {
    const opts = this.props.filterOptions;
    return( opts.requireFeedback &&
            opts.one &&
            opts.two &&
            opts.three &&
            opts.four &&
            opts.five)
  }

  _isShowingCriticalOnly() {
    const opts = this.props.filterOptions;
    return( opts.requireFeedback &&
            opts.one &&
            opts.two &&
            opts.three &&
            !opts.four &&
            !opts.five)
  }

  render() {
    const on = this.props.filterOptions;

    return (
      <div className="btn-toolbar" role="toolbar">
        <div className="btn-group mr-auto mb-2" role="group" aria-label="First group">
          <button type="button" onClick={this._showAll} className={`btn ${this._isShowingAll() ? 'btn-primary' : 'btn-light'}`}>All</button>
          <button type="button" onClick={this._showNotableOnly} className={`btn ${this._isShowingNotableOnly() ? 'btn-primary' : 'btn-light'}`}>Notable</button>
          <button type="button" onClick={this._showCriticalOnly} className={`btn ${this._isShowingCriticalOnly() ? 'btn-primary' : 'btn-light'}`}>Critical</button>
        </div>
        <div className="btn-group mb-2 mr-2" role="group" aria-label="First group">
          <button type="button" onClick={this._toggleCohort} className={`btn ${on.cohort ? 'btn-primary' : 'btn-light'}`} title="Show selected cohort only" data-toggle="tooltip">
          <i className="fa fa-users" />
          </button>
          <button type="button" onClick={this._toggleFeedbackRequirement} className={`btn ${on.requireFeedback ? 'btn-primary' : 'btn-light'}`} title="Show only feedback which contains text (10 characters or more)" data-toggle="tooltip">
            <i className="fa fa-comments" />
          </button>
        </div>
        <div className="btn-group mb-2" role="group" aria-label="First group">
          <button type="button" onClick={this._toggleRating.bind(this, 'one')} className={`btn ${on.one ? 'btn-primary' : 'btn-light'}`}>1</button>
          <button type="button" onClick={this._toggleRating.bind(this, 'two')} className={`btn ${on.two ? 'btn-primary' : 'btn-light'}`}>2</button>
          <button type="button" onClick={this._toggleRating.bind(this, 'three')} className={`btn ${on.three ? 'btn-primary' : 'btn-light'}`}>3</button>
          <button type="button" onClick={this._toggleRating.bind(this, 'four')} className={`btn ${on.four ? 'btn-primary' : 'btn-light'}`}>4</button>
          <button type="button" onClick={this._toggleRating.bind(this, 'five')} className={`btn ${on.five ? 'btn-primary' : 'btn-light'}`}>5</button>
        </div>
      </div>
    );
  }
}
