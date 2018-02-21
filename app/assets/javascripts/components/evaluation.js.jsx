var Evaluation = React.createClass({

  handleClick: function() {
    ga('send', 'event', 'start-marking-evaluation', 'click');
  },

  renderMarkingButton: function(){
    var evaluation = this.props.evaluation;
    if(!this.props.active){
      return (
        <p>
          <a className="btn btn-primary btn-lg" href={`/projects/${evaluation.project.slug}/evaluations/${evaluation.id}/start_marking`} data-method="put" onClick={this.handleClick}>Start Marking</a>
        </p>
      )
    } else {
      return (
        <p>
          <a className="btn btn-primary btn-lg" href={`/projects/${evaluation.project.slug}/evaluations/${evaluation.id}/edit`}>Continue Marking</a>
        </p>
      )
    }
  },

  renderResubmissionLabel: function(){
    if (this.props.evaluation.resubmission) {
      return(
        <span className="badge badge-danger">Resubmission</span>
      )
    }
  },

  renderProject: function(){
    var evaluation = this.props.evaluation;

    if(evaluation.project)
      return (
        <div>
          <p>
            <b>Project:&nbsp;</b>
            <a href={"projects/" + evaluation.project.slug}>
              {evaluation.project.name} &nbsp;
            </a>
            { this.renderResubmissionLabel() }
          </p>
          <p>
            <b>Submission URL:&nbsp;</b>
            <a target="_blank" href={evaluation.github_url}>
              {evaluation.github_url}
            </a>
          </p>
        </div>
      )
  },

  render: function() {
    var evaluation = this.props.evaluation;
    var student = evaluation.student;

    return (
      <RequestItem student={student} location={this.props.location}>
        <p className="assistance-timestamp">
          Evaluation
          <abbr className="timeago" title="{evaluation.created_at}">
            <TimeAgo date={evaluation.created_at} />
          </abbr>
        </p>

        { this.renderProject() }

        { this.renderMarkingButton() }
      </RequestItem>
    )
  }
});
