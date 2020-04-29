window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useEffect = React.useEffect;
const useReducer = React.useReducer;
const useContext = React.useContext;

const initialState = {
  connected: false,
  lastUpdate: 0,
  channel: {},
  requestUpdates: [],
  queueUpdates: [],
  teacherUpdates: []
};

const resetSequence = (updates) => {
  const offset = updates[updates.length -1].sequence;
  return updates.map(update => {
    return {...update, sequence: update.sequence - offset};
  })
}

const messageLookup = {
  'queueUpdate': (state, updates) => {
    return {...state, lastUpdate: updates[updates.length - 1].sequence, queueUpdates: [...updates]}
  },
  'teacherUpdate': (state, updates) => {
    // not used yet
    return {...state, lastUpdate: updates[updates.length - 1].sequence, teacherUpdates: [...updates]}
  },
  'requestUpdate': (state, updates) => {
    const sequence = updates[updates.length - 1].sequence;
    return {...state, lastUpdate: sequence, requestUpdates: [...state.requestUpdates, ...updates]}
  }
}

const reducer = (state, action) => {
  switch (action.type) {
    case 'disconnect':
      return {...state, connected: false};
    case 'connect':
      return {...state, connected: true};
    case 'setChannel':
      return {...state, channel: action.data.socket, connected: action.data.connected };
    case 'socketMessage':
      const updates = Array.isArray(action.data.object) ? action.data.object : [{object: action.data.object, sequence: action.data.sequence}]
      return updates.length > 0 ? messageLookup[action.data.type](state, updates) : state
    default:
      throw new Error();
  }
}

window.NationalQueue.useQueueSocket = (user) => {
  const socketContext = window.NationalQueue.SocketContext;
  const socketHandler = useContext(socketContext);
  const [queueChannel, dispatchQueueChannel] = useReducer(reducer, initialState);
  
  useEffect(() => {
    // set up handlers for action cable
    socketHandler.onRecieved = (data) => {
      console.log('recieved', data);
      dispatchQueueChannel({type: 'socketMessage', data});
    };
    socketHandler.onConnected = () => {
      dispatchQueueChannel({type: 'connect'});
      if (queueChannel.lastUpdate > 0) {
        // re-establishing connection
        socketHandler.socket.perform('get_missed_updates', {sequence: queueChannel.lastUpdate});
      } else {
        socketHandler.socket.perform('assistance_request_state');
      }
    };
    socketHandler.onDisconnect = () => {
      dispatchQueueChannel({type: 'disconnect'});
    };

    if (socketHandler.connected && queueChannel.lastUpdate === 0) {
      // socket connected before hook was initialized
      socketHandler.socket.perform('assistance_request_state');
    }

    dispatchQueueChannel({type: 'setChannel', data: socketHandler});
    
    return () => {
      socketHandler.onRecieved = null;
      socketHandler.onConnected = null;
      socketHandler.onDisconnect = null;
    }
  }, [queueChannel.lastUpdate])

  const requestAssistance = (reason, activityId) => {
    queueChannel.channel.perform('request_assistance', {reason: reason, activity_id: activityId});
  }

  const cancelAssistanceRequest = (request) => {
    queueChannel.channel.perform('cancel_assistance_request', {request_id: request && request.id});
  }

  const startAssisting = (request) => {
    queueChannel.channel.perform('start_assisting', {request_id: request.id});
  }

  const cancelAssistance = (request) => {
    queueChannel.channel.perform('cancel_assistance', {request_id: request.id});
  }

  const finishAssistance = (request, notes, notify, rating) => {
    queueChannel.channel.perform('finish_assistance', {request_id: request.id, notes, notify, rating});
  }

  const cancelEvaluating = (evaluation) => {
    queueChannel.channel.perform('cancel_evaluating', {evaluation_id: evaluation.id});
  }

  const startEvaluating = (evaluation) => {
    queueChannel.channel.perform('start_evaluating', {evaluation_id: evaluation.id});
  }

  const cancelInterview = (interview) => {
    queueChannel.channel.perform('cancel_interview', {tech_interview_id: interview.id});
  }

  const provideAssistance = (student, notes, notify, rating) => {
    queueChannel.channel.perform('provide_assistance', {requestor_id: student.id, notes, notify, rating});
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
    provideAssistance,
    requestUpdates: queueChannel.requestUpdates,
    queueUpdates: queueChannel.queueUpdates,
    teacherUpdates:queueChannel.teacherUpdates
  }

}