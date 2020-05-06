window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useReducer = React.useReducer;
const useEffect = React.useEffect;

const statisticsReducer = (state, action) => {
  switch (action.type) {
    case 'setTimeFilter':
      return {...state, filters: {...state.filters, time: action.data}};
    case 'setTasks':
      return {...state, loading: false, queueTasks: action.data.tasks};
    case 'error':
      return {...state, loading: false, error: action.data}
    case 'loading':
      return {...state, loading: true}
    default:
      throw new Error();
  }
};

window.NationalQueue.useQueueStatistics = (user) => {
  const [statistics, dispatchStatistics] = useReducer(statisticsReducer, {loading: true, queueTasks: [], filters: {time: 'day'}});
  useEffect(() => {
    dispatchStatistics({type: 'loading'});
    fetch(`/queue_tasks/${user.id}`, {
      headers: {
        "Content-Type": "application/json"
      }
    })
      .then(response => {
        if (response.status === 200) {
          return response.json()
        } else {
          dispatchStatistics({type: 'error', data: 'Could not fetch queue data!'})
        }
      })
      .then((response) => {
        dispatchStatistics({type: "setTasks", data: response});
      });

  }, [user]);

  const setTimeFilter = (time) => {
    dispatchStatistics({type: 'setTimeFilter', data: time});
  }

  const filteredQueueTasks = () => {
    const today = moment(new Date());
    if (statistics.filters.time === 'month') {
      return statistics.queueTasks
    }
    return statistics.queueTasks.filter(queueTask => {
      const queueTaskDate = moment(new Date(queueTask.startedAt));
      if (statistics.filters.time === 'day') {
        return today.isSame(queueTaskDate, "day");
      } else {
        return today.isSame(queueTaskDate, "week");
      }
    });
  }

  const userAssistances = (queueTasks) => {
    return queueTasks.reduce((acc, task) => {
      if (task.taskObject && task.taskObject.assistor && task.taskObject.assistor.id === user.id) {
        acc.push(task);
      }
      return acc;
    }, []);
  }

  const filteredAvgRating = (tasks) => {
    let tasksWithRating = 0;
    const sum =  tasks.reduce((sumRating, task) => {
      if (task.taskObject.assistorRating) {
        tasksWithRating ++;
        return (parseInt(sumRating) || 0) + task.taskObject.assistorRating;
      } else {
        return sumRating;
      }
    }, '-');
    return sum === '-' ? sum : sum/tasksWithRating;
  }

  const filteredAvgWait = (tasks) => {
    let tasksWithValidDifference = 0; 
    const sumTime =  tasks.reduce((sumDifference, task) => {
      const difference = Date.parse(task.taskObject.assistanceStart) - Date.parse(task.createdAt);
      if (difference > 0) {
        tasksWithValidDifference ++;
        return (parseInt(sumDifference) || 0) + difference;
      } else {
        return sumDifference;
      }
    }, '-');
    return sumTime === '-' ? sumTime : Math.round((sumTime / 1000 / 60)) / tasksWithValidDifference + ' min';
  }

  const queueTasks = filteredQueueTasks();
  const assistances = userAssistances(queueTasks);
  const avgRating = filteredAvgRating(assistances);
  const avgWait = filteredAvgWait(assistances);

  return {
    setTimeFilter,
    assistances,
    queueTasks,
    avgRating,
    avgWait,
    loading: statistics.loading,
    timeFilter: statistics.filters.time
  }

}
