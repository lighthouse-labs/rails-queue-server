window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useReducer = React.useReducer;
const useEffect = React.useEffect;


window.NationalQueue.useTasks = (updates, user) => {
  // no imports have to load in selectors here
  const {selectOpen, selectAllOpen, selectPending, selectInProgress, tasksWithUpdates} = window.NationalQueue.QueueSelectors;
  // reducer should be moved outside of hook, but without imports selectors have to be required inside hook
  const taskReducer = (state, action) => {
    switch (action.type) {
      case 'setTasks':
        return action.data;
      case 'addUpdates':
        return tasksWithUpdates(state, action.data);
      default:
        throw new Error();
    }
  };
  const [taskState, dispatchTaskState] = useReducer(taskReducer, []);

  useEffect(() => {
    fetch(`/queue_tasks`, {
      headers: {
        "Content-Type": "application/json"
      }
    })
      .then(response => response.json())
      .then((response) => {
        let tasks = response.tasks || [];
        tasks = _(tasks).sortBy((item) => {
          return (item.startAt || item.startedAt || item.createdAt)
        }).reverse();
        dispatchTaskState({type: "setTasks", data: Array.from(tasks)});
      });

  }, [])

  useEffect(() => {
    dispatchTaskState({type: 'addUpdates', data: updates});
  },[updates]);


  const pendingEvaluations = () => {
    return selectPending(taskState);
  }

  const inProgress = () => {
    return selectInProgress(taskState);
  }

  const myOpenTasks = () => {
    return selectOpen(taskState, user);
  }

  const allOpenTasks = () => {
    return selectAllOpen(taskState, user);
  }

  return {
    pendingEvaluations,
    inProgress,
    myOpenTasks,
    allOpenTasks
  }

}