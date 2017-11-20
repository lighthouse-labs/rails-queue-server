var TechInterviewTemplate = React.createClass({
  
    render: function() {
  
      return (
        <div>
          <h4>
            Week {this.props.week} Interview
            <small> - <i>{this.props.cohortName}</i> </small>
          </h4>
          <p>{this.props.description}</p>
          <a className="btn btn-primary btn-lg" href={`/tech_interview_templates/${this.props.id}?cohort=${this.props.cohortId}`}>View Interview</a>
        </div>
      )
    }
  
  })