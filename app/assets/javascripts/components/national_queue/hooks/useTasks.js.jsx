window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useReducer = React.useReducer;
const useEffect = React.useEffect;


window.NationalQueue.useTasks = (updates, user) => {
  // no imports have to load in selectors here
  const {selectOpen, selectPending, selectInProgress, tasksWithUpdates} = window.NationalQueue.QueueSelectors;
  // reducer should be moved outside of hook, but without imports selectors have to be required inside hook
  const taskReducer = (state, action) => {
    switch (action.type) {
      case 'setTasks':
        return {...state, tasks: action.data};
      case 'addUpdates':
        let updates = action.data;
        let lastUpdate = state.lastUpdate;

        for (let index = updates.length -1; index >= 0; index --) {
          if (updates[index].sequence <= lastUpdate) {
            updates = updates.slice(index+1);
            break;
          } else {
            lastUpdate = updates[index].sequence;
          }
        }
        return {...state, tasks: tasksWithUpdates(state.tasks, updates), lastUpdate};
      default:
        throw new Error();
    }
  };
  const [taskState, dispatchTaskState] = useReducer(taskReducer, {tasks: [], lastUpdate: 0});
  

  useEffect(() => {
    // eventually evaluations assistances and interviews could be linked to queue_tasks
    const evaluationsRequest = fetch(`/queue_tasks/evaluations`, {
      headers: {
        "Content-Type": "application/json"
      }
    })
    const tasksRequest = fetch(`/queue_tasks`, {
      headers: {
        "Content-Type": "application/json"
      }
    })
    const interviewsRequest = fetch(`/queue_tasks/tech_interviews`, {
      headers: {
        "Content-Type": "application/json"
      }
    })
    Promise.all([ tasksRequest, evaluationsRequest, interviewsRequest])
      .then(responses => Promise.all(responses.map(response => response.json())))
      .then((responses) => {
        const tasks = responses[0].tasks || [];
        const evaluations = responses[1].evaluations || [];
        const interviews = responses[2].interviews || [];
        let taskList = tasks.concat(evaluations).concat(interviews);
        taskList = _(taskList).sortBy((item) => {
          return (item.startAt || item.startedAt || item.createdAt)
        }).reverse();
        dispatchTaskState({type: "setTasks", data: Array.from(taskList)});
      });

  }, [])

  useEffect(() => {
    console.log("useeffect triggered in use task for update", updates);
    dispatchTaskState({type: 'addUpdates', data: updates});
  },[updates]);

  const pendingEvaluations = () => {
    return selectPending(taskState.tasks);
  }

  const inProgress = () => {
    return selectInProgress(taskState.tasks);
  }

  const openTasks = () => {
    return selectOpen(taskState.tasks, user);
  }

  return {
    pendingEvaluations,
    inProgress,
    openTasks
  }

}