window.Queue || (window.Queue = {});

window.Queue.InProgressList = class InProgressList extends React.Component {
  propTypes: {
    assistances: PropTypes.array
  }

  renderAssistance(assistance) {
    return <Queue.Assistance key={`assistance-${assistance.id}`} assistance={assistance} />
  }

  renderAssistances() {
    return this.props.assistances.map(this.renderAssistance);
  }

  render() {
    return (
      <div className="card card-default">
        <div className="card-header clearfix">
          <h5 className="card-title">
            <span className="count">{this.props.assistances.length}</span>
            <span className="title">In Progress</span>
          </h5>
        </div>
        <ul className="list-group">
          {this.renderAssistances()}
        </ul>
      </div>
    );
  }
}

