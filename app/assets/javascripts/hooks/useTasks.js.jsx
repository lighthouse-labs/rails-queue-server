window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useReducer = React.useReducer;
const useEffect = React.useEffect;


window.NationalQueue.useTasks = (updates, user, refresh) => {
  // no imports have to load in selectors here
  const {selectOpen, selectAllOpen, selectPending, selectInProgress, tasksWithUpdates} = window.NationalQueue.QueueSelectors;
  // reducer should be moved outside of hook, but without imports selectors have to be required inside hook
  const taskReducer = (state, action) => {
    switch (action.type) {
      case 'setTasks':
        const tasks = action.data.reduce(function(result, item) {
          result[item.id+item.type] = item;
          return result;
        }, {})
        return {...state, tasks};
      case 'addUpdates':
        return {...state, tasks: tasksWithUpdates(state.tasks, action.data)};
      case 'error':
        return {...state, error: action.data}
      default:
        throw new Error();
    }
  };
  const [taskState, dispatchTaskState] = useReducer(taskReducer, {tasks: [], error: null});

  useEffect(() => {
    fetch(`/queue_tasks`, {
      headers: {
        "Content-Type": "application/json"
      }
    })
      .then(response => {
        if (response.status === 200) {
          return response.json()
        } else {
          dispatchTaskState({type: 'error', data: 'Could not fetch queue data!'})
        }
      })
      .then((response) => {
        let tasks = response.tasks || [];
        tasks = _(tasks).sortBy((item) => {
          return (item.startAt || item.startedAt || item.createdAt)
        });
        dispatchTaskState({type: "setTasks", data: Array.from(tasks)});
      });

  }, [refresh])

  useEffect(() => {
    dispatchTaskState({type: 'addUpdates', data: updates});
  },[updates]);

  const arrayOfTasks = () => {
    return Array.from(_(Object.values(taskState.tasks)).sortBy((item) => {
      return (item.startAt || item.startedAt || item.createdAt)
    }));
  }

  const pendingEvaluations = () => {
    return selectPending(arrayOfTasks());
  }

  const inProgress = () => {
    return selectInProgress(arrayOfTasks());
  }

  const myOpenTasks = (otherUser) => {
    return selectOpen(arrayOfTasks(), otherUser || user);
  }

  const allOpenTasks = () => {
    return selectAllOpen(arrayOfTasks(), user);
  }

  return {
    pendingEvaluations,
    inProgress,
    myOpenTasks,
    allOpenTasks,
    error: taskState.error
  }

}