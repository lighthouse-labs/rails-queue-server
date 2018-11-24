window.Queue || (window.Queue = {});

window.Queue.App = class App extends React.Component {
  propTypes: {
    queue: PropTypes.object
  }

  constructor(props) {
    super(props);
    this.state = {
      queue: this.props.queue
    }
  }

  setupSubscription() {
    if(window.App.queue) return; // App.queue.unsubscribe();

    // window.App.cable is only set (from cable.js) on DOM loaded
    // This isn't normally the case in Rails but how we do it
    // This is why we have this subscription created within a DOM Loaded callback
    // - KV
    $(() => {
      window.App.queue = window.App.cable.subscriptions.create({ channel: "QueueChannel" }, {
        connected: () => {
          //console.log('!! QUEUE CHANNEL CONNECTED');
        },
        disconnected: () => {
          //console.log('!! QUEUE CHANNEL DISCONNECTED');
        },
        received: (data) => {
          this.setState(JSON.parse(data));
        },
        cancelAssistanceRequest: function(request) {
          this.perform('cancel_assistance_request', {request_id: request.id})
        },
        startAssisting: function(request) {
          this.perform('start_assisting', {request_id: request.id})
        },
        stopAssisting: function(assistance) {
          this.perform('stop_assisting', {assistance_id: assistance.id})
        }
      });
    });
  }

  fetchQueueData() {
    $.getJSON('/queue.json').then((data) => this.setState(data));
    this.setupSubscription();
  }

  componentDidMount() {
    // get the data :)
    if (!this.state.queue) {
      this.fetchQueueData();
    }
  }

  renderLocation(location) {
    return(
      <Queue.Location key={`location-${location.id}`} location={location} />
    )
  }

  renderLocations() {
    const locations = this.state.queue.locations;
    return locations.map(this.renderLocation);
  }

  render() {
    if (this.state.queue) {
      return (
        <div className="queue-container">
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

