window.NationalQueue = window.NationalQueue || {};

const selectOpen = (tasks, user) => {
 return tasks.filter((task) => {
  return (task.teacher && task.teacher.id === user.id) && task.state === 'pending' && task.type === 'Assistance';
 })
}

const selectAllOpen = (tasks) => {
  const matches = {};
  return tasks.filter((task, index) => {
    if (task.state === 'pending' && task.type === 'Assistance'){
      if (matches[task.taskObject.id]) {
        matches[task.taskObject.id].teachers.push(task.teacher);
      } else {
        task.teachers = [task.teacher];
        matches[task.taskObject.id] = task;
        return true;
      } 
    }
  })
 }

const selectPending = (tasks) => {
  return tasks.filter((task) => {
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
  selectAllOpen,
  selectPending,
  selectInProgress,
  tasksWithUpdates
}