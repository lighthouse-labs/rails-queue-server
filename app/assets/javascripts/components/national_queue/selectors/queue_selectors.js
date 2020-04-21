window.NationalQueue = window.NationalQueue || {};

const selectOpen = (tasks, user) => {
 return tasks.filter((task) => {
  return (task.teacher && task.teacher.id === user.id) && task.state === 'pending' && task.type !== 'ProjectEvaluation';
 })
}

const selectPending = (tasks) => {
  console.log('select pending', tasks);
  return tasks.filter((task) => {
    console.log('task', task.state, task.type)
    return task.state === 'pending' && task.type === 'ProjectEvaluation';
  })
}

const selectInProgress = (tasks) => {
  return tasks.filter((task) => {
    return task.state === 'in_progress';
  })
}

const tasksWithUpdates = (tasks, updates) => {
  tasks = [...tasks];
  for (update of updates) {
    let updated = false;
    for ([index, task] of tasks.entries()) {
      if (task.id === update.object.id && task.type === update.object.type) {
        tasks[index] = update.object;
        updated = true;
        break;
      }
    }
    if (!updated) {
      tasks.push(update.object);
    }
  }
  return Array.from(_(tasks).sortBy((item) => {
    return (item.startAt || item.startedAt || item.createdAt)
  }).reverse());
}

window.NationalQueue.QueueSelectors =  {
  selectOpen,
  selectPending,
  selectInProgress,
  tasksWithUpdates
}