var TechInterview = React.createClass({

  renderButtons: function(){
    var interview = this.props.interview;
    var interviewTemplate = interview.tech_interview_template;

    if(!this.props.active){
      return (
        <p>
          <a className="btn btn-primary btn-lg" href={`/tech_interviews/${interview.id}/start`} data-method="patch">Start Interview</a>
        </p>
      )
    } else {
      return (
        <p>
          <a className="btn btn-primary btn-lg" href={`/tech_interviews/${interview.id}/edit`}>Continue Interviewing</a>
          &nbsp;
          <a className="btn btn-danger btn-lg" data-toggle="tooltip" title="Put it back into the queue for someone (else) to pick up later." href={`/tech_interviews/${interview.id}/stop`} data-method="patch">Stop Interviewing</a>
        </p>
      )
    }
  },

  renderInterviewTemplate: function(){
    var interview = this.props.interview;
    var interviewTemplate = interview.tech_interview_template;

    if(interviewTemplate)
      return (
        <div>
          <p>
            <b>Interview:</b>
            <a href={"tech_interview_templates/" + interviewTemplate.id}>
              Week {interviewTemplate.week}
            </a>
          </p>
        </div>
      )
  },

  render: function() {
    var interview = this.props.interview;
    var student = interview.interviewee;

    return (
      <RequestItem student={student} location={this.props.location}>
        <p className="assistance-timestamp">
          Tech Interview
          <abbr className="timeago" title="{interview.created_at}">
            <TimeAgo date={interview.created_at} />
          </abbr>
        </p>

        { this.renderInterviewTemplate() }

        { this.renderButtons() }
      </RequestItem>
    )
  }
});
