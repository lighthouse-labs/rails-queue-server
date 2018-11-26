window.Queue || (window.Queue = {});

window.Queue.InProgressList = class InProgressList extends React.Component {
  propTypes: {
    assistances: PropTypes.array.isRequired,
    evaluations: PropTypes.array.isRequired,
    interviews: PropTypes.array.isRequired
  }

  renderAssistance = (assistance) => {
    return <Queue.Assistance key={`assistance-${assistance.id}`} assistance={assistance} />
  }

  renderEvaluation = (evaluation) => {
    return <Queue.Evaluation key={`evaluation-${evaluation.id}`} evaluation={evaluation} />
  }

  renderInterview = (interview) => {
    return <Queue.Interview key={`interview-${interview.id}`} interview={interview} />
  }

  renderItem = (item) => {
    if (item.type === 'Assistance') {
      return this.renderAssistance(item)
    } else if (item.type === 'ProjectEvaluation') {
      return this.renderEvaluation(item)
    } else if (item.type === 'TechInterview') {
      return this.renderInterview(item)
    }
  }

  renderAssistances() {
    return this.props.assistances.map(this.renderAssistance);
  }

  renderInterviews() {
    return this.props.interviews.map(this.renderInterview);
  }

  renderEvaluations() {
    return this.props.evaluations.map(this.renderEvaluation);
  }

  renderItems(items) {
    console.log('items: ', items);
    return items.map(this.renderItem);
  }

  getItems() {
    let items = this.props.assistances.concat(this.props.evaluations).concat(this.props.interviews);
    items = _(items).sortBy((item) => {
      return (item.startAt || item.startedAt || item.createdAt)
    }).reverse();
    return Array.from(items);
  }

  render() {
    const items = this.getItems();

    return (
      <div className="card card-default">
        <div className="card-header clearfix">
          <h5 className="card-title">
            <span className="count">{this.props.assistances.length + this.props.evaluations.length + this.props.interviews.length}</span>
            <span className="title">In Progress</span>
          </h5>
        </div>
        <ul className="list-group">
          {this.renderItems(items)}
        </ul>
      </div>
    );
  }
}

