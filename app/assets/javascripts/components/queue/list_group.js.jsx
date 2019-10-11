window.Queue || (window.Queue = {});

window.Queue.ListGroup = class ListGroup extends React.Component {
  propTypes: {
    count: PropTypes.number.isRequired,
    title: PropTypes.string.isRequired
  }

  constructor(props) {
    super(props);
    this.state = {
      collapsed: this.checkCollapsed()
    };
  }

  checkCollapsed() {
    return window.localStorage.getItem(`${this.props.title} - collapsed`) === 'y';
  }

  handleToggleCollapse = () => {
    if (this.state.collapsed) {
      this.setState({collapsed: false });
      window.localStorage.setItem(`${this.props.title} - collapsed`, 'n');
    } else {
      this.setState({collapsed: true });
      window.localStorage.setItem(`${this.props.title} - collapsed`, 'y');
    }
  }

  render() {
    return(
      <div className={`card card-default ${this.state.collapsed ? 'collapsed' : ''}`}>
        <div className="card-header clearfix" onClick={this.handleToggleCollapse}>
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