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
  tasks = {...tasks};
  for (update of updates) {
    tasks[update.object.id+update.object.type] = update.object;
  }
  return tasks;
}

const teachersWithUpdates = (teachers, updates) => {
  teachers = {...teachers};
  for (update of updates) {
    const teacher = update.object;
    if (teacher.onDuty) {
      teachers[teacher.id] = teacher;
    } else {
      delete teachers[teacher.id];
    }
  }
  return teachers;
}

const studentsWithUpdates = (students, updates) => {
  students = [...students];
  for (update of updates) {
    const task = update.object;
    if (task.type === 'Assistance' && task.taskObject.assistor) {
      for (student of students) {
        if (updateForStudent(task, student)) {
          student.lastAssistedAt = Date.now();
          break;
        }
      }
    }
  }
  return Array.from(_(students).sortBy((student) => {
    return (student.lastAssistedAt)
  }));
}

const cohortsWithUpdates = (cohorts, updates) => {
  cohorts = [...cohorts];
  for (update of updates) {
    const task = update.object;
    if (task.type === 'TechInterview' && task.taskObject.completedAt) {
      for ([index, cohort] of cohorts.entries()) {
        if (cohort.id === task.taskObject.interviewee.cohort.id) {
          cohorts[index] = {...cohort, interviewStatuses: updateInterviewStatuses(cohort.interviewStatuses, task.taskObject)};
        }
      }
    }
  }
  return cohorts;
}

const updateInterviewStatuses = (interviewStatuses, interview) => {
  interviewStatuses = [...interviewStatuses];
  for ([index, interviewStatus] of interviewStatuses.entries()) {
    if (interview.techInterviewTemplate.week === interviewStatus.week) {
      const incomplete = interviewStatus.incompleteStudentIds;
      const studentPosition = incomplete.indexOf(interview.interviewee.id);

      if (studentPosition >= 0) {
        const incompleteStudentIds = [...incomplete];
        incompleteStudentIds.splice(studentPosition, 1)
        interviewStatuses[index] = {
          ...interviewStatus,
          incompleteStudentIds,
          completedStudentIds: [...interviewStatus.completedStudentIds, interview.interviewee.id]
        }
      }
    }
  }
  return interviewStatuses;
}

const updateForStudent = (task, student) => {
  return  task.taskObject.requestor.id === student.id;
}

window.NationalQueue.QueueSelectors =  {
  selectOpen,
  selectAllOpen,
  selectPending,
  selectInProgress,
  tasksWithUpdates,
  teachersWithUpdates,
  studentsWithUpdates,
  cohortsWithUpdates
}