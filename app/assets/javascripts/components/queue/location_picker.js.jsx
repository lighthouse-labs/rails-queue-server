window.Queue || (window.Queue = {});

window.Queue.LocationPicker = class LocationPicker extends React.Component {
  propTypes: {
    locations: PropTypes.array.isRequired,
    selectedLocation: PropTypes.object
  }

  constructor(props) {
    super(props);
    this.state = {
      selectedLocation: this.props.selectedLocation || this.props.myLocation || this.props.locations[0]
    }
  }

  selectLocation = (location) => {
    this.setState({ selectedLocation: location })
    this.props.onLocationChange(location);
  }

  renderLocationChooser(location) {
    const active = (this.state.selectedLocation && (this.state.selectedLocation.id === location.id) ? 'active' : null);
    return (
      <a key={location.id} className={`nav-item nav-link ${active}`} href="javascript:void(0)" onClick={this.selectLocation.bind(this, location)}>
        {location.name}
        &nbsp;
        <span className="badge badge-light">{location.requests.length}</span>
      </a>
    )
  }

  renderLocations(locations) {
    return locations.map(this.renderLocationChooser.bind(this))
  }

  render() {
    const locations = this.props.locations;

    return (
      <nav className="nav nav-pills mb-3">
        {this.renderLocations(locations)}
      </nav>
    );
  }
}
