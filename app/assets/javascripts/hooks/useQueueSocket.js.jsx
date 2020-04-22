window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useEffect = React.useEffect;
const useReducer = React.useReducer;

const initialState = {
  connected: false,
  lastUpdate: 0,
  channel: {},
  requestUpdates: [],
  queueUpdates: [],
  teacherUpdates: []
};

const messageLookup = {
  'queueUpdate': (state, updates) => {
    console.log('Queue updated recieved', updates);
    return {...state, lastUpdate: updates[updates.length - 1].sequence, queueUpdates: [...state.queueUpdates, ...updates]}
  },
  'teacherUpdate': (state, updates) => {
    return {...state, lastUpdate: updates[updates.length - 1].sequence, teacherUpdates: [...state.teacherUpdates, ...updates]}
  },
  'requestUpdate': (state, updates) => {
    console.log('Request updated recieved', updates);
    return {...state, lastUpdate: updates[updates.length - 1].sequence, requestUpdates: [...state.requestUpdates, ...updates]}
  }
}

const reducer = (state, action) => {
  switch (action.type) {
    case 'disconnect':
      return {...state, connected: false};
    case 'connect':
      return {...state, connected: true};
    case 'setChannel':
      return {...state, channel: action.data };
    case 'socketMessage':
      const updates = Array.isArray(action.data.object) ? action.data.object : [{object: action.data.object, sequence: action.data.sequence}]
      return messageLookup[action.data.type](state, updates)
    default:
      throw new Error();
  }
}

window.NationalQueue.useQueueSocket = (user) => {
  // no imports have to load in selectors here  
  const [queueChannel, dispatchQueueChannel] = useReducer(reducer, initialState);
  useEffect(() => {
    // connect to student or teacher channel
    // dont like this, should not use global to store channel, but need the channel to persist
    window.NationalQueue.channel = window.NationalQueue.channel || App.cable.subscriptions.create({ channel: "NationalQueueChannel"}, {
      received(data) {
        dispatchQueueChannel({type: 'socketMessage', data});
      },
      disconnected() {
        dispatchQueueChannel({type: 'disconnect'});
      },
      connected() {
        dispatchQueueChannel({type: 'connect'});
        if (queueChannel.lastUpdate > 0) {
          this.perform('get_missed_updates', lastUpdate)
        }
      },
      requestAssistance(reason, activityId) {
        this.perform('request_assistance', {reason: reason, activity_id: activityId});
      },
      cancelAssistanceRequest(request) {
        this.perform('cancel_assistance_request', {request_id: request && request.id});
      },
      startAssisting(request) {
        this.perform('start_assisting', {request_id: request.id});
      },
      cancelAssistance(request) {
        this.perform('cancel_assistance', {request_id: request.id});
      },
      finishAssistance(request, notes, notify, rating) {
        this.perform('finish_assistance', {request_id: request.id, notes, notify, rating});
      },
      cancelEvaluating(evaluation) {
        this.perform('cancel_evaluating', {evaluation_id: evaluation.id});
      },
      startEvaluating(evaluation) {
        this.perform('start_evaluating', {evaluation_id: evaluation.id});
      },
      cancelInterview(interview) {
        this.perform('cancel_interview', {tech_interview_id: interview.id});
      }
    });

    dispatchQueueChannel({type: 'setChannel', data: window.NationalQueue.channel});
    
    return () => {
      // no clean up possible because channel has to stay live when component is not rendered
      // & no root component to mount the hook/context
      // window.NationalQueue.channel.unsubscribe();
    }
  }, [])

  const requestAssistance = (reason, activityId) => {
    queueChannel.channel.requestAssistance(reason, activityId);
  }

  const cancelAssistanceRequest = (request) => {
    queueChannel.channel.cancelAssistanceRequest(request)
  }

  const startAssisting = (request) => {
    queueChannel.channel.startAssisting(request)
  }

  const cancelAssistance = (request) => {
    queueChannel.channel.cancelAssistance(request)
  }

  const finishAssistance = (request, notes, notify, rating) => {
    queueChannel.channel.finishAssistance(request, notes, notify, rating);
  }

  const cancelEvaluating = (evaluation) => {
      queueChannel.channel.cancelEvaluating(evaluation);
  }

  const startEvaluating = (evaluation) => {
    queueChannel.channel.startEvaluating(evaluation);
  }

  const cancelInterview = (interview) => {
    queueChannel.channel.cancelInterview(interview);
  }

  return {
    requestAssistance,
    cancelAssistanceRequest,
    startAssisting,
    cancelAssistance,
    queueChannel,
    finishAssistance,
    cancelEvaluating,
    startEvaluating,
    cancelInterview,
    requestUpdates: queueChannel.requestUpdates,
    queueUpdates: queueChannel.queueUpdates,
    teacherUpdates:queueChannel.teacherUpdates
  }

}