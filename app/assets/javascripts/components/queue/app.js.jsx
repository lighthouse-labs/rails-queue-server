window.Queue || (window.Queue = {});

window.Queue.App = class App extends React.Component {
  propTypes: {
    queue: PropTypes.object
  }

  constructor(props) {
    super(props);
    const queue = this.props.queue || window.App.queue.readFromCache();
    console.log('cached queue content: ', queue);
    this.state = {
      myLocation:   this.props.myLocation,
      queue:        queue,
      connected:    false,
      disconnects:  0
    }
  }

  componentDidMount() {
    // get the data :)
    this.registerApp();
    // no callback needed since we registered the app and it will call our setState
    window.App.queue.fetch();
  }

  componentWillUnmount() {
    console.log('unmounting queue.app');
    window.App.queue.unregisterApp();
  }

  registerApp() {
    window.App.queue.registerApp(this);
    window.App.queue.connect();
    this.setState({connected: window.App.queue.isConnected()});
  }

  handleLocationChange = (location) => {
    this.setState({
      selectedLocation: location
    })
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

  render() {
    if (this.state.queue) {
      const disabled   = this.state.connected ? '' : 'disabled';
      const myLocation = this.state.myLocation;
      const locations  = this.onlyVisibleLocations(myLocation);
      const selectedLocation = this.getSelectedLocation(locations);

      return (
        <div className={`queue-container ${disabled}`}>
          <Queue.LocationPicker onLocationChange={this.handleLocationChange}
                                locations={locations}
                                myLocation={myLocation}
                                selectedLocation={selectedLocation} />
          <Queue.Locations      locations={locations}
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

