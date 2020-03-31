window.ActivityFeedback || (window.ActivityFeedback = {});

window.ActivityFeedback.App = class App extends React.Component {

  propTypes: {
    activityId: PropTypes.number.required
  }

  constructor(props) {
    super(props);
    this.state = this.getDefaultState();
  }

  getDefaultState() {
    return {
      feedbacks: [],
      paginationOptions: {
        page: 1
      },
      filterOptions: {
        cohortID: this.props.cohort,
        filterByCohort: false,
        requireFeedback: true,
        one: true,
        two: true,
        three: true,
        four: true,
        five: true
      },
      meta: {}
    }
  }

  reset() {
    const freshState = this.getDefaultState();
    freshState.feedbacks = this.state.feedbacks;
    freshState.loading = true;
    freshState.filterOptions.requireFeedback = false;
    this.setState(freshState);
    this._fetchInitial();
  }

  componentDidMount() {
    // hack so that outsider can call .reset() on me later
    window.App.activityFeedbackApp = this;

    // Initial load
    this._fetchInitial();
  }

  componentWillUnmount() {
    // hack so that outsider can call .reset() on me later
    window.App.activityFeedbackApp = undefined;
    // in case an xhr request is giong on
    this._abortRequest();
  }

  _fetchAndThen(options, then) {
    this._abortRequest();
    this.setState({ loading: true });
    const url = `/activities/${this.props.activityId}/activity_feedbacks.json`;
    this.xhr = $.getJSON(url, options);
    this.xhr.then(json => {
      this.xhr = undefined;
      const newState = {
        meta: json.meta,
        paginationOptions: {
          page: json.meta.nextPage
        },
        loading: false
      }
      then(newState, json);
    });
  }

  _fetchInitial() {
    this.setState({ paginationOptions: { page: 1 } })
    const options = Object.assign({}, this.state.filterOptions, this.state.paginationOptions);
    options.page = 1;
    this._fetchAndThen(options, (newState, json) => {
      newState.feedbacks = json.activity_feedbacks;
      this.setState(newState);
    })
  }

  _fetchMore() {
    const options = Object.assign({}, this.state.filterOptions, this.state.paginationOptions);
    this._fetchAndThen(options, (newState, json) => {
      newState.feedbacks = this.state.feedbacks.concat(json.activity_feedbacks);
      this.setState(newState);
    })
  }

  _abortRequest() {
    if (this.xhr && this.xhr.abort) {
      this.xhr.abort();
      this.xhr = undefined;
    }
  }

  _onFilterChange = (filterOptions) => {
    const options = Object.assign({}, filterOptions, this.state.paginationOptions);
    options.page = 1;

    this._fetchAndThen(options, (newState, json) => {
      newState.feedbacks = json.activity_feedbacks;
      this.setState(newState);
    });
  }

  _changeFilters = (filterChange) => {
    this._abortRequest();

    const currentFilterOptions = this.state.filterOptions;
    const newFilterOptions = Object.assign({}, currentFilterOptions, filterChange)

    this.setState({
      filterOptions:      newFilterOptions,
      loading:            true,
      paginationOptions:  { page: 1 }
    });
    this._onFilterChange(newFilterOptions);
  }

  render() {
    return(
      <div className="activity-feedback-app">
        <ActivityFeedback.Filters meta={this.state.meta}
                                  filterOptions={this.state.filterOptions}
                                  changeFilters={this._changeFilters} />

        <ActivityFeedback.FeedbackList  feedbacks={this.state.feedbacks}
                                        loading={this.state.loading}
                                        meta={this.state.meta}
                                        handleNextPage={this._handleNextPage} />
      </div>
    );
  }

  _handleNextPage = () => {
    this._fetchMore();
  }
}
