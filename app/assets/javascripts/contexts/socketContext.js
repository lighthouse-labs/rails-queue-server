window.NationalQueue = window.NationalQueue || {};
const notify = (title, options) => {
  if (!("Notification" in window)) {
    console.log('notifications not supported');
  } else if (Notification.permission === "granted") {
    new Notification(title, options);
  } else if (Notification.permission !== "denied") {
    Notification.requestPermission().then(function (permission) {
      if (permission === "granted") {
        new Notification(title, options);
      }
    });
  }
}

const notificationBody = (request) => {
  const week = request.requestor.cohort.week;
  return `[Week ${week}] ${request.reason}\r\n(Notified b/c you're marked as on duty)`;
}

const notificationHandler = (data) => {
  if (data.type === 'queueUpdate') {
    const update = Array.isArray(data.object) ? data.object[data.object.length - 1] : data.object;
    if (shouldUpdate(window.current_user, update)) {
      const assistanceRequest = update.taskObject;
      const title = `Assistance Requested by ${assistanceRequest.requestor.firstName} ${assistanceRequest.requestor.lastName}`;
      const options = {
        body: notificationBody(assistanceRequest),
        icon: assistanceRequest.requestor.avatarUrl
      }
      notify(title, options);
    }
  }
}

const shouldUpdate = (user, update) => {
  return (user.onDuty && !user.busy) && update && update.state === 'pending' && update.type === 'Assistance' && user.id === update.teacher.id;
}

if(window.App?.cable) {
  const socketHandler = {
    socket: App.cable.subscriptions.create({ channel: "NationalQueueChannel"}, {
      received(data) {
        socketHandler.onRecieved && socketHandler.onRecieved(data);
        notificationHandler(data);
      },
      disconnected() {
        socketHandler.connected = false;
        socketHandler.onDisconnect && socketHandler.onDisconnect();
      },
      connected() {
        socketHandler.connected = true;
        socketHandler.onConnected && socketHandler.onConnected();
      }
    }),
    connected: false,
    onRecieved: () => {},
    onDisconnect: () => {},
    onConnect: () => {}
  }
  window.NationalQueue.SocketContext = React.createContext(socketHandler);
}
