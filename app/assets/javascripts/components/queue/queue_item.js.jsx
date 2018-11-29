window.Queue || (window.Queue = {});

window.Queue.QueueItem = class QueueItem extends React.Component {
  propTypes: {
    type: PropTypes.string.isRequired
  }

  render() {
    const type = this.props.type;
    const disabled = this.props.disabled ? 'disabled' : ''

    return(
      <li className={`${_.kebabCase(type)} ${disabled} list-group-item clearfix`}>
        <div className="type">
          <div className="text">{ type }</div>
        </div>

        { this.props.children }
      </li>
    );
  }
}