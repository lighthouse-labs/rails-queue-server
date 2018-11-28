window.Queue || (window.Queue = {});

window.Queue.ListGroup = class ListGroup extends React.Component {
  propTypes: {
    count: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired
  }

  constructor(props) {
    super(props);
  }

  render() {
    return(
      <div className="card card-default">
        <div className="card-header clearfix">
          <h5 className="card-title">
            <span className="count">{this.props.count}</span>
            <span className="title">{this.props.title}</span>
          </h5>
        </div>
        <ul className="list-group">
          { this.props.children }
        </ul>
      </div>
    )
  }
}