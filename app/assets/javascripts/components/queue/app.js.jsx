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

  renderLocation(selectedLocation, location) {
    if (selectedLocation && selectedLocation.id === location.id) {
      return(
        <Queue.Location key={`location-${location.id}`} location={location} />
      )
    }
  }

  renderLocations() {
    const locations = this.state.queue.locations;
    return locations.map(this.renderLocation.bind(this, this.getSelectedLocation()));
  }

  getSelectedLocation() {
    return this.state.selectedLocation || this.state.myLocation || (this.state.queue && this.state.queue.locations[0])
  }

  render() {
    if (this.state.queue) {
      const disabled = this.state.connected ? '' : 'disabled';
      const locations = this.state.queue.locations;

      return (
        <div className={`queue-container ${disabled}`}>
          <Queue.LocationPicker onLocationChange={this.handleLocationChange}
                                locations={locations}
                                myLocation={this.state.myLocation}
                                selectedLocation={this.getSelectedLocation()} />
          {this.renderLocations()}
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

