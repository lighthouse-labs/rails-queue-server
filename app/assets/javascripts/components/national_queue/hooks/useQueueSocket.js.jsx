window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useEffect = React.useEffect;
const useReducer = React.useReducer;

const initialState = {
  connected: false,
  channel: {},
  requestUpdates: [],
  queueUpdates: [],
  teacherUpdates: []
};

const messageLookup = {
  'queueUpdate': (state, update) => {
    console.log('Queue updated recieved', update);
    return {...state, queueUpdates: [...state.queueUpdates, update]}
  },
  'teacherUpdate': (state, update) => {
    return {...state, teacherUpdates: [...state.teacherUpdates, update]}
  },
  'requestUpdate': (state, update) => {
    console.log('Request updated recieved', update);
    return {...state, requestUpdates: [...state.requestUpdates, update]}
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
      return messageLookup[action.data.type](state, {object: action.data.object, sequence: action.data.sequence})
    default:
      throw new Error();
  }
}

window.NationalQueue.useQueueSocket = (user) => {
  // no imports have to load in selectors here  
  const [queueChannel, dispatchQueueChannel] = useReducer(reducer, initialState);
  useEffect(() => {
    // connect to student or teacher channel
    const channel = App.cable.subscriptions.create({ channel: "NationalQueueChannel"}, {
      received(data) {
        dispatchQueueChannel({type: 'socketMessage', data});
      },
      disconnected() {
        dispatchQueueChannel({type: 'disconnect'});
      },
      connected() {
        dispatchQueueChannel({type: 'connect'});
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
      }
    });

    dispatchQueueChannel({type: 'setChannel', data: channel});
    
    return () => {
      channel.unsubscribe();
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

  return {
    requestAssistance,
    cancelAssistanceRequest,
    startAssisting,
    cancelAssistance,
    queueChannel,
    finishAssistance,
    cancelEvaluating,
    startEvaluating,
    requestUpdates: queueChannel.requestUpdates,
    queueUpdates: queueChannel.queueUpdates,
    teacherUpdates:queueChannel.teacherUpdates
  }

}