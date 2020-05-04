window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useReducer = React.useReducer;
const useEffect = React.useEffect;

const updateCurrentUser = (user, updates) => {
  for (update of updates.reverse()) {
    if (user.id === update.object.id) {
      user = update.object;
      break;
    }
  }
  return user;
}

window.NationalQueue.useTeachers = (updates, user) => {
  // no imports have to load in selectors here
  const {teachersWithUpdates} = window.NationalQueue.QueueSelectors;
  // reducer should be moved outside of hook, but without imports selectors have to be required inside hook
  const teacherReducer = (state, action) => {
    switch (action.type) {
      case 'setTeachers':
        const teachers = action.data.reduce(function(result, item) {
          result[item.id] = item;
          return result;
        }, {})
        return {...state, teachers};
      case 'addUpdates':
        return {...state, currentUser: updateCurrentUser(state.currentUser, action.data), teachers: teachersWithUpdates(state.teachers, action.data)};
      case 'error':
        return {...state, error: action.data}
      default:
        throw new Error();
    }
  }
  const [teachersState, dispatchTeachersState] = useReducer(teacherReducer, {currentUser: user, teachers: {}, error: null});

  useEffect(() => {
    fetch(`/queue_tasks/teachers`, {
      headers: {
        "Content-Type": "application/json"
      }
    })
      .then(response => {
        if (response.status === 200) {
          return response.json();
        } else {
          dispatchTeachersState({type: 'error', data: 'Could not fetch teacher data!'});
        }
      })
      .then((response) => {
        let teachers = response.teachers || [];
        dispatchTeachersState({type: "setTeachers", data: teachers});
      });

  }, [])

  useEffect(() => {
    dispatchTeachersState({type: 'addUpdates', data: updates});
  },[updates]);

  const teacherOnDuty = (teacher) => {
    return teachersState.teachers[teacher.id] && teachersState.teachers[teacher.id].onDuty;
  }

  return {
    currentUser: teachersState.currentUser,
    teachers: Object.values(teachersState.teachers),
    teacherOnDuty,
    error: teachersState.error
  }

}
