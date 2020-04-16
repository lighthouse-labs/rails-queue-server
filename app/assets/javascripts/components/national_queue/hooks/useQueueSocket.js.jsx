window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;
const useEffect = React.useEffect;

window.NationalQueue.useQueueSocket = (user) => {
  // no imports have to load in selectors here  
  const [studentChannels, setStudentChannels] = useState({
    connected: false,
    updates: []
  });
  const [TeacherChannels, setTeacherChannels] = useState({
    connected: false,
    updates: []
  });

  useEffect(() => {
    // connect to student or teacher channel
    App.cable.subscriptions.create({ channel: "NationalQueueChannel"}, {
      received(data) {
        console.log(data);
      },
      disconnected() {
        setStudentChannel((channel) => ({...channel, connected: false}));
      },
      connected() {
        setStudentChannel((channel) => ({...channel, connected: true}));
      },
      requestAssistance(reason, activityId) {
        this.perform('request_assistance', {reason: reason, activity_id: activityId});
      },
      cancelAssistanceRequest() {
        this.perform('cancel_assistance');
      }
    });

    return () => {
      App.nationalQueueChannel.unsubscribe();
    }
  }, [])

  const requestAssistance = (reason, activityId) => {
    window.App.nationalQueueChannel.requestAssistance(reason, activityId);
  }

  const cancelAssistance = () => {
    window.App.nationalQueueChannel.cancelAssistanceRequest()
  }


  return {
    requestAssistance,
    cancelAssistance,
    studentChannel,
    teacherChannel
  }

}