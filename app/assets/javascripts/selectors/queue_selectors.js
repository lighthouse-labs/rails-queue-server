window.NationalQueue = window.NationalQueue || {};

const selectOpen = function(tasks, user) {
 return tasks.filter(function(task) {
  return (task.teacher && task.teacher.id === user.id) && task.state === 'pending' && task.type === 'Assistance';
 })
}

const selectAllOpen = function(tasks) {
  const matches = {};
  return tasks.filter(function(task) {
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

const selectPending = function(tasks) {
  return tasks.filter(function(task) {
    return task.state === 'pending' && task.type === 'ProjectEvaluation';
  })
}

const selectInProgress = function(tasks) {
  return tasks.filter(function(task) {
    return task.state === 'in_progress';
  })
}

const tasksWithUpdates = function(tasks, updates) {
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
  return Array.from(_(tasks).sortBy(function(item) {
    return (item.startAt || item.startedAt || item.createdAt)
  }));
}

window.NationalQueue.QueueSelectors =  {
  selectOpen,
  selectAllOpen,
  selectPending,
  selectInProgress,
  tasksWithUpdates
}