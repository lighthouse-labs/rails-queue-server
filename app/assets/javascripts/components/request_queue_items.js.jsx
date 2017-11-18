var RequestQueueItems = React.createClass({

  renderAssisting: function() {
    var that = this;
    if(this.props.activeAssistances.length > 0) {
      return (
        <div>
          <h3 className="section-heading">Currently Assisting</h3>
          <ul className="student-list">
            {
              this.props.activeAssistances.map(function(assistance) {
                return <Assistance assistance={assistance} key={assistance.id} location={that.props.location}/>
              })
            }
          </ul>
        </div>
      )
    }
  },

  renderRequests: function() {
    var that = this;
    if(this.props.requests.length > 0)
      return this.props.requests.map(function(request) {
        return <Request request={request} key={request.id} location={that.props.location} />
      })
    else
      return <i>This queue is empty.  Good job!</i>
  },

  codeReviewHolder: function() {
    if(this.props.location.has_code_reviews)
      return(
        <div>
          <h3 className="section-heading">Awaiting Code Review</h3>
          <ul className="student-list">
            { this.renderCodeReviews() }
          </ul>
        </div>
      )
  },


  renderCodeReviews: function() {
    var that = this;
    if(this.props.codeReviews.length > 0)
      return this.props.codeReviews.map(function(codeReview) {
        return <CodeReview codeReview={codeReview} key={codeReview.id} location={that.props.location} />
      })
    else
      return <i>There aren&#39;t any code reviews</i>
  },

  activeEvaluationHolder: function(){
    if(this.props.activeEvaluations.length > 0){
      return(
        <div>
          <h3 className="section-heading">Currently Marking:</h3>
          <ul className="student-list">
            { this.renderActiveEvaluations() }
          </ul>
        </div>
      )
    }
  },

  activeTechInterviewHolder: function(){
    if(this.props.activeTechInterviews.length > 0){
      return(
        <div>
          <h3 className="section-heading">Currently Tech Interviewing:</h3>
          <ul className="student-list">
            { this.renderActiveTechInterviews() }
          </ul>
        </div>
      )
    }
  },

  renderActiveTechInterviews: function(){
    var that = this;
    return this.props.activeTechInterviews.map(function(techInterview){
      return <TechInterview interview={techInterview} key={techInterview.id} location={that.props.location} active={true}/>
    });
  },

  renderActiveEvaluations: function(){
    var that = this;
    return this.props.activeEvaluations.map(function(evaluation){
      return <Evaluation evaluation={evaluation} key={evaluation.id} location={that.props.location} active={true}/>
    });
  },

  evaluationHolder: function(){
    return(
      <div>
        <h3 className="section-heading">Awaiting Project Evaluations</h3>
        <ul className="student-list">
          { this.renderEvaluations() }
        </ul>
      </div>
    )
  },

  techInterviewTemplateHolder: function(){
    return(
      <div>
        <h3 className="section-heading">Tech Interviews This Week</h3>
        <ul className="student-list">
          { this.renderTechInterviewTemplates() }
        </ul>
      </div>
    )
  },

  renderTechInterviewTemplates: function(){
    var that = this;
    if(this.props.techInterviewTemplates.length > 0)
      return this.props.techInterviewTemplates.map(function(template, idx){
        console.log(that.props.cohorts[idx]);
        return <TechInterviewTemplate week={template.week} id={ template.id } description={template.description} cohort={that.props.cohorts[idx].cohort.name} />
      });
    else
      return <i>There are no tech interviews this week.</i>
  },

  techInterviewHolder: function(){
    return(
      <div>
        <h3 className="section-heading">Awaiting Tech Interviews</h3>
        <ul className="student-list">
          { this.renderTechInterviews() }
        </ul>
      </div>
    )
  },

  renderEvaluations: function(){
    var that = this;
    if(this.props.evaluations.length > 0)
      return this.props.evaluations.map(function(evaluation){
        return <Evaluation evaluation={ evaluation } key={ evaluation.id } location={that.props.location} active={false}/>
      });
    else
      return <i>There aren&#39;t any evaluations</i>
  },

  renderTechInterviews: function(){
    var that = this;
    if(this.props.techInterviews.length > 0)
      return this.props.techInterviews.map(function(interview){
        return <TechInterview interview={ interview } key={ interview.id } location={that.props.location} active={false}/>
      });
    else
      return <i>There aren&#39;t any tech interviews.</i>
  },

  renderStudents: function() {
    var that = this;
    return this.props.students.map(function(student) {
      return <Student student={student} key={student.id} location={that.props.location} />
    })
  },

  render: function() {
    return (
      <div className="requests-list">

        { this.renderAssisting() }
        { this.activeEvaluationHolder() }
        { this.activeTechInterviewHolder() }

        <h3 className="section-heading">Awaiting Assistance</h3>
        <ul className="student-list">
          { this.renderRequests() }
        </ul>

        { this.techInterviewTemplateHolder() }

        { this.codeReviewHolder() }

        { this.evaluationHolder() }

        <h3 className="section-heading">All Students</h3>
        <ul className="student-list">
          { this.renderStudents() }
        </ul>
      </div>
    )
  }
})
