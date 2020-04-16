window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useEffect = React.useEffect;

window.NationalQueue.useTasks = (user) => {
  // no imports have to load in selectors here
  const {selectActive, selectPending, selectInProgress} = window.NationalQueue.QueueSelectors;
  
  const [tasks, setTasks] = useState({
    evaluations: [],
    queueTasks: [],
    interviews: []
  });

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
    Promise.all([evaluationsRequest, tasksRequest, interviewsRequest])
      .then(responses => responses.map(response => response.json()))
      .then((responses) => {
        console.log(responses[0].body);
        console.log(responses[1].body);
        console.log(responses[2].body);

        // setTasks({
        //   evaluations: JSON.parse(responses[0].body).evaluations,
        //   queueTasks: JSON.parse(responses[1].body).tasks,
        //   interviews: JSON.parse(responses[2].body).interviews
        // })
      });

  }, [])

  const allTasks = () => {
    let taskList = tasks.queueTasks.concat(tasks.evaluations).concat(tasks.interviews);
    taskList = _(taskList).sortBy((item) => {
      return (item.startAt || item.startedAt || item.createdAt)
    }).reverse();
    return Array.from(taskList);
  }

  const pendingEvaluations = () => {
    return selectPending(tasks.evaluations);
  }

  const inProgress = () => {
    return selectInProgress(allTasks());
  }

  const openTasks = () => {
    return selectActive(allTasks());
  }


  return {
    pendingEvaluations,
    inProgress,
    openTasks
  }

}