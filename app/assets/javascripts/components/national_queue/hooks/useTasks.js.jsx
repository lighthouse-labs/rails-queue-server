window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useEffect = React.useEffect;
const {selectActive, selectPending, selectInProgress} = window.NationalQueue.QueueSelectors

window.NationalQueue.useTasks = ({user}) => {
  const [tasks, setTasks] = useState({
    evaluations: [],
    assistances: [],
    interviews: []
  });

  useEffect(() => {
    //get evaluations asssistances interviews
  }, [])

  const allTasks = () => {
    let tasks = assistances.concat(evaluations).concat(interviews);
    tasks = _(tasks).sortBy((item) => {
      return (item.startAt || item.startedAt || item.createdAt)
    }).reverse();
    return Array.from(tasks);
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