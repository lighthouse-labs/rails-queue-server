window.NationalQueue = window.NationalQueue || {};

const selectActive = (tasks) => {
 return tasks.filter((task) => {
  return true
 })
}

const selectPending = (tasks) => {
  return tasks.filter((task) => {
    return true
  })
}

const selectInProgress = (tasks) => {
  return tasks.filter((task) => {
    return true
  })
}


window.NationalQueue.QueueSelectors =  {
  selectActive,
  selectPending,
  selectInProgress
}