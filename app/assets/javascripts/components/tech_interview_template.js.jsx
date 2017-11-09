var TechInterviewTemplate = React.createClass({
  
    render: function() {
  
      return (
        <div>
          <h4>Week {this.props.week} Interview</h4>
          <p>{this.props.description}</p>
          <a className="btn btn-primary btn-lg" href={`/tech_interview_templates/${this.props.id}#students`}>Students</a>
        </div>
      )
    }
  
  })