var RequestQueue = React.createClass({

  propTypes: {
    locations: React.PropTypes.array.isRequired,
    user: React.PropTypes.object.isRequired
  },

  componentWillMount: function() {
    var location;

    if(this.props.user.location)
      location = this.props.user.location;
    else
      location = this.props.locations[0];

    this.setState({location: location});
  },

  componentDidMount: function() {
    this.loadQueue();
    this.requestNotificationPermission();
    document.title = "Compass | Queue";
  },

  componentDidUpdate: function(prevProps, prevState) {
    if(prevState.location.id != this.state.location.id)
      this.loadQueue();
  },

  requestNotificationPermission: function() {
    that = this;
    switch(Notification.permission) {
    case "granted":
      this.setState({canNotify: true})
      break;
    default:
      Notification.requestPermission(function(e) {
        if(e == "granted") {
          that.setState({canNotify: true})
        }
      });
    }
  },

  getInitialState: function() {
    return {
      activeAssistances: [],
      requests: [],
      codeReviews: [],
      activeEvaluations: [],
      evaluations: [],
      activeTechInterviews: [],
      techInterviews: [],
      students: [],
      techInterviewTemplates: [],
      cohorts: [],
      hasNotification: ("Notification" in window),
      canNotify: false,

    }
  },

  loadQueue: function() {
    $.getJSON("/assistance_requests/queue?location=" + this.state.location.name, this.requestSuccess);
    this.subscribeToSocket();
  },

  requestSuccess: function(response) {

    this.setState({
      activeAssistances: response.active_assistances,
      requests: response.requests,
      codeReviews: response.code_reviews,
      activeEvaluations: response.active_evaluations,
      evaluations: response.evaluations,
      activeTechInterviews: response.active_tech_interviews,
      techInterviews: response.tech_interviews,
      students: response.all_students,
      techInterviewTemplates: response.tech_interview_templates,
      cohorts: response.cohorts
    });
  },

  subscribeToSocket: function() {
    var that = this;
    if(App.assistance)
      App.assistance.unsubscribe();

    App.assistance = App.cable.subscriptions.create({ channel: "AssistanceChannel", location: this.state.location.name }, {
      rejected: function() {
        window.location.reload()
      },
      startAssisting: function(request) {
        this.perform('start_assisting', {request_id: request.id})
      },
      endAssistance: function(assistance, notes, rating, notify) {
        this.perform('end_assistance', {assistance_id: assistance.id, notes: notes, rating: rating, notify: notify})
      },
      providedAssistance: function(student, notes, rating, notify) {
        this.perform('provided_assistance', {student_id: student.id, notes: notes, rating: rating, notify: notify})
      },
      cancelAssistanceRequest: function(request) {
        this.perform('cancel_assistance_request', {request_id: request.id})
      },
      stopAssisting: function(assistance) {
        this.perform('stop_assisting', {assistance_id: assistance.id})
      },

      received: function(data) {
        switch(data.type) {
          case "AssistanceRequest":
            that.handleAssistanceRequest(data.object);
            break;
          case "CodeReviewRequest":
            that.handleCodeReviewRequest(data.object);
            break;
          case "CancelAssistanceRequest":
            that.removeFromQueue(data.object)
            break;
          case "AssistanceStarted":
            that.handleAssistanceStarted(data.object);
            break;
          case "AssistanceEnded":
            that.handleAssistanceEnd(data.object.assistance_request)
            break;
          case "OffineAssistanceCreated":
            that.updateLastAssisted(data.object);
            break;
          case "StoppedAssisting":
            that.removeFromQueue(data.object.assistance_request);

            var assistanceRequest = data.object.assistance_request;
            if(assistanceRequest.activity_submission)
              that.handleCodeReviewRequest(assistanceRequest);
            else
              that.handleAssistanceRequest(assistanceRequest);

            break;
          case "EvaluationRequest":
            that.handleEvaluationRequest(data.object)
            break;
          case "NewTechInterview":
            that.handleTechInterviewRequest(data.object)
            break;
          case "TechInterviewStopped":
            that.handleTechInterviewRequest(data.object)
            that.removeFromActiveTechInterviews(data.object)
            break;
          case "TechInterviewStarted":
            that.removeFromTechInterviews(data.object)
            break;
          case "StartMarking":
            that.removeFromQueue(data.object);
            break;
        }
      },
      disconnected: function() {
        $('.reconnect-holder').delay(500).show(0)
      },
      connected: function() {
        if ($('.reconnect-holder').is(':visible')) {
          $('.reconnect-holder').hide()
        }
      }
    });
  },

  handleAssistanceRequest: function(assistanceRequest) {
    var requests = this.state.requests;
    if(this.getRequestIndex(assistanceRequest) === -1 && this.inLocation(assistanceRequest)) {
      requests.push(assistanceRequest);
      requests.sort(function(a,b){
        return new Date(a.start_at) - new Date(b.start_at);
      })
      this.setState({requests: requests});

      this.html5Notification(assistanceRequest);
    }
  },

  html5Notification: function(assistanceRequest) {
    if(this.state.hasNotification && this.state.canNotify) {
      new Notification(
        "Assistance Requested by " + assistanceRequest.requestor.first_name + ' ' + assistanceRequest.requestor.last_name,
        {
          body: assistanceRequest.requestor.cohort.name + "\r\n" + (assistanceRequest.reason || ''),
          icon: assistanceRequest.requestor.avatar_url
        }
      );
    }
  },

  handleCodeReviewRequest: function(codeReviewRequest) {
    var codeReviews = this.state.codeReviews;
    if(this.inLocation(codeReviewRequest)) {
      codeReviews.push(codeReviewRequest);
      codeReviews.sort(function(a,b){
        return new Date(a.start_at) - new Date(b.start_at);
      })
      this.setState({codeReviews: codeReviews});
    }
  },

  removeFromQueue: function(assistanceRequest) {
    this.removeAssistanceFromRequests(assistanceRequest);
    this.removeFromAssisting(assistanceRequest);
    this.removeFromCodeReviews(assistanceRequest);
    this.removeFromEvaluations(assistanceRequest);
  },

  handleAssistanceStarted: function(assistance) {
    this.removeAssistanceFromRequests(assistance.assistance_request);
    this.removeFromCodeReviews(assistance.assistance_request);
    if(assistance.assistor.id === this.props.user.id) {
      var activeAssistances = this.state.activeAssistances;
      activeAssistances.push(assistance);
      this.setState({activeAssistances: activeAssistances});
    }
  },

  handleAssistanceEnd: function(assistance) {
    this.removeFromQueue(assistance)
    this.updateLastAssisted(assistance.requestor)
  },

  updateLastAssisted: function(student) {
    var students = this.state.students
    var ind = this.getStudentIndex(student);
    if (ind > -1) {
      students[ind].last_assisted_at = new Date;
      this.setState({students: students})
    }
  },

  removeAssistanceFromRequests: function(assistanceRequest) {
    var requests = this.state.requests;
    var ind = this.getRequestIndex(assistanceRequest);
    if(ind > -1) {
      requests.splice(ind, 1);
      this.setState({requests: requests});
    }
  },

  removeFromAssisting: function(assistanceRequest) {
    var activeAssistances = this.state.activeAssistances;
    var ids = activeAssistances.map(function(a) {
      return a.assistance_request.id;
    });

    var ind = ids.indexOf(assistanceRequest.id);
    if(ind > -1) {
      activeAssistances.splice(ind, 1);
      this.setState({activeAssistances: activeAssistances});
    }
  },

  removeFromCodeReviews: function(assistanceRequest) {
    var codeReviews = this.state.codeReviews;
    var ids = codeReviews.map(function(cr) {
      return cr.id;
    });

    var ind = ids.indexOf(assistanceRequest.id);
    if(ind > -1) {
      codeReviews.splice(ind, 1);
      this.setState({codeReviews: codeReviews});
    }
  },

  removeFromEvaluations: function(assistanceRequest){
    var evaluations = this.state.evaluations;
    var ids = evaluations.map(function(e){
      return e.id;
    });

    var ind = ids.indexOf(assistanceRequest.id);
    if(ind > -1){
      evaluations.splice(ind, 1);
      this.setState({evaluations: evaluations});
    }
  },

  removeFromTechInterviews: function(interview){
    var interviews = this.state.techInterviews;
    var ids = interviews.map(function(e){
      return e.id;
    });

    var ind = ids.indexOf(interview.id);
    if(ind > -1){
      interviews.splice(ind, 1);
      this.setState({techInterviews: interviews});
    }
  },

  removeFromActiveTechInterviews: function(interview){
    var interviews = this.state.activeTechInterviews;
    var ids = interviews.map(function(e){
      return e.id;
    });

    var ind = ids.indexOf(interview.id);
    if(ind > -1) {
      interviews.splice(ind, 1);
      this.setState({activeTechInterviews: interviews});
    }
  },

  inLocation: function(assistanceRequest) {
    return assistanceRequest.requestor.cohort.location.id === this.state.location.id;
  },

  getRequestIndex: function(assistanceRequest) {
    var requests = this.state.requests;
    var ids = requests.map(function(r){
      return r.id;
    });

    return ids.indexOf(assistanceRequest.id);
  },

  getStudentIndex: function(student) {
    var students = this.state.students;
    var ids = students.map(function(s){
      return s.id;
    });

    return ids.indexOf(student.id);
  },

  locationChanged: function(event) {
    var locationNames = this.props.locations.map(function(l) { return l.name });
    var ind = locationNames.indexOf(event.target.value);
    this.setState({location: this.props.locations[ind]});
  },

  renderLocations: function() {
    var that = this;

    if(this.props.user.location)
      return (
        <div id="cohort-locations">
          Cohort locations:
          {
            this.props.locations.map(function(location) {
              return (
                <label key={location.id}>
                  <input
                    type="radio"
                    value={location.name}
                    checked={that.state.location.id == location.id}
                    onChange={that.locationChanged} />
                    { location.name }
                </label>
              )
            })
          }
        </div>
      )
    else
      return (
        <div id="cohort-locations">
          Looks like your profile doesn&#39;t have a location!
        </div>
      )
  },

  handleEvaluationRequest: function(evaluation){
    var evaluations = this.state.evaluations;
    evaluations.push(evaluation)
    this.setState({evaluations: evaluations})
  },

  handleTechInterviewRequest: function(interview){
    var techInterviews = this.state.techInterviews;
    techInterviews.push(interview)
    this.setState({techInterviews: techInterviews})
  },

  render: function() {
    return(
      <div>
        { this.renderLocations() }
        <RequestQueueItems
          activeAssistances={this.state.activeAssistances}
          requests={this.state.requests}
          codeReviews={this.state.codeReviews}
          activeEvaluations={this.state.activeEvaluations}
          evaluations={this.state.evaluations}
          activeTechInterviews={this.state.activeTechInterviews}
          techInterviews={this.state.techInterviews}
          students={this.state.students}
          cohorts={this.state.cohorts}
          techInterviewTemplates={this.state.techInterviewTemplates}
          location={this.state.location} />
      </div>
    )
  }
})
