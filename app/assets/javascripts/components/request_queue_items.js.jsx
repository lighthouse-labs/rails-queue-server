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

  renderActiveEvaluations: function(){
    var that = this;
    return this.props.activeEvaluations.map(function(evaluation){
      return <Evaluation evaluation={evaluation} key={evaluation.id} location={that.props.location} active={true}/>
    });
  },

  evaluationHolder: function(){
    return(
      <div>
        <h3 className="section-heading">Awaiting Evaluations</h3>
        <ul className="student-list">
          { this.renderEvaluations() }
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

        <h3 className="section-heading">Awaiting Assistance</h3>
        <ul className="student-list">
          { this.renderRequests() }
        </ul>

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
