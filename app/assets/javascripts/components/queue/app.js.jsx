window.Queue || (window.Queue = {});

window.Queue.App = class App extends React.Component {
  propTypes: {
    queue: PropTypes.object
  }

  constructor(props) {
    super(props);
    const queue = this.props.queue || window.App.queue.readFromCache();

    window.current_user = this.props.user || window.current_user;

    this.state = {
      myLocation:   window.current_user.location,
      queue:        queue,
      connected:    false,
      refreshing:   false,
      disconnects:  0
    }
  }

  componentDidMount() {
    // register this app to the queue manager class, which will notify us of important data/state changes
    this.registerApp();
    // get the data :)
    // no callback needed since we registered the app and it will call our setState
    window.App.queue.fetch();
  }

  componentWillUnmount() {
    // otherwise the queue mgr will obliviously be setting state on unmounted react component
    window.App.queue.unregisterApp();
  }

  registerApp() {
    window.App.queue.registerApp(this);
    window.App.queue.connect();
    this.setState({connected: window.App.queue.isConnected()});
  }

  // external callback (from Queue manager: queue.coffee)
  connected() {
    this.setState({connected: true});
    // It's not an initial connect, but a retry. Let's refetch queue state!
    if (this.state.disconnects > 0) {
      window.App.queue.fetch();
    }
  }

  // external callback (from Queue manager: queue.coffee)
  disconnected() {
    this.setState({
      disconnects: this.state.disconnects + 1,
      connected: false
    });
  }

  // external callback (from Queue manager: queue.coffee)
  updateData(data) {
    const state = Object.assign({}, data, { refreshing: false });
    this.setState(state)
  }

  handleLocationChange = (location) => {
    this.setState({ selectedLocation: location })
  }

  getSelectedLocation(locations) {
    return this.state.selectedLocation || this.state.myLocation || (locations && locations[0])
  }

  onlyVisibleLocations(myLocation) {
    return (this.state.queue.locations || []).filter((location) => {
      return (
        (location.students.length > 0) ||
        (location.pendingEvaluations.length > 0) ||
        (location.inProgressEvaluations.length > 0) ||
        (myLocation && location.id === myLocation.id)
      );
    });
  }

  hardRefresh = () => {
    if (this.state.refreshing) return;
    this.setState({ refreshing: true });
    window.App.queue.fetch(true);
  }

  render() {
    if (this.state.queue) {
      const disabled   = this.state.connected && !this.state.refreshing ? '' : 'disabled';
      const myLocation = this.state.myLocation;
      const locations  = this.onlyVisibleLocations(myLocation);
      const selectedLocation = this.getSelectedLocation(locations);
      const refreshBtnClass = this.state.refreshing ? 'rotating' : '';

      return (
        <div className={`queue-container ${disabled}`}>
          <div className="clearfix mb-2">
            <div className="pull-left mr-2">
              <Queue.LocationPicker onLocationChange={this.handleLocationChange}
                                    locations={locations}
                                    myLocation={myLocation}
                                    selectedLocation={selectedLocation} />
            </div>
            <div className="pull-left">
              <button onClick={this.hardRefresh} className={`btn btn-refresh btn-outline btn-secondary ${refreshBtnClass}`} title="A 'hard refresh' shouldn't be needed, but just incase you're having trust issues still ;)">
                <i className="fa fa-refresh"></i>
              </button>
            </div>
          </div>

          <Queue.Locations  locations={locations}
                            myLocation={myLocation}
                            selectedLocation={selectedLocation} />
        </div>
      );
    }

    return (
      <div className="row">
        LOADING ...
      </div>
    );

  }
}

