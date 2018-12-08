window.Queue || (window.Queue = {});

window.Queue.QueueItem = class QueueItem extends React.Component {
  propTypes: {
    type: PropTypes.string,
    label: PropTypes.string
  }

  render() {
    const type = this.props.type;
    const disabled = this.props.disabled ? 'disabled' : '';
    const label = this.props.label || this.props.type;

    return(
      <li className={`${_.kebabCase(type)} ${disabled} list-group-item clearfix`}>
        <div className="type">
          <div className="text">{ label }</div>
        </div>

        { this.props.children }
      </li>
    );
  }
}