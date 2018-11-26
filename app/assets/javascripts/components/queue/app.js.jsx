window.Queue || (window.Queue = {});

window.Queue.App = class App extends React.Component {
  propTypes: {
    queue: PropTypes.object
  }

  constructor(props) {
    super(props);
    const queue = this.readCacheQueueData();
    this.state = {
      queue: this.props.queue || queue,
      connected: false,
      disconnects: 0
    }
  }

  setupSubscription() {
    if(window.App.queue) {
      this.setState({connected: true});
      return;
    };

    // window.App.cable is only set (from cable.js) on DOM loaded
    // This isn't normally the case in Rails but how we do it
    // This is why we have this subscription created within a DOM Loaded callback
    // - KV
    $(() => {
      window.App.queue = window.App.cable.subscriptions.create({ channel: "QueueChannel" }, {
        connected: () => {
          this.setState({connected: true});
          // TODO: Only do this if it's a reconnect vs an initial connect;
          if (this.state.disconnects > 0) this.fetchQueueData();
        },
        disconnected: () => {
          let disconnects = this.state.disconnects;
          this.setState({connected: false, disconnects: disconnects+1 });
        },
        received: (data) => {
          this.setState(JSON.parse(data));
        },
        cancelAssistanceRequest: function(request) {
          this.perform('cancel_assistance_request', {request_id: request.id});
        },
        startAssisting: function(request) {
          this.perform('start_assisting', {request_id: request.id});
        },
        stopAssisting: function(assistance) {
          this.perform('stop_assisting', {assistance_id: assistance.id});
        },
        startEvaluating: function(evaluation) {
          this.perform('start_evaluating', {evaluation_id: evaluation.id});
        },
        cancelEvaluating: function(evaluation) {
          this.perform('cancel_evaluating', {evaluation_id: evaluation.id});
        }
      });
    });
  }

  fetchQueueData() {
    $.getJSON('/queue.json').then((data) => {
      this.setState(data);
      this.writeCacheQueueData(data);
    });
    this.setupSubscription();
  }

  writeCacheQueueData(data) {
    window.localStorage.setItem('queue', JSON.stringify(data.queue));
  }

  readCacheQueueData() {
    const data = localStorage.getItem('queue');
    if (data) {
      return JSON.parse(data);
    }
  }

  componentDidMount() {
    // get the data :)
    this.fetchQueueData();
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
    console.log('here');
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

