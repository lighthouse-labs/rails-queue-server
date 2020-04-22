window.NationalQueue = window.NationalQueue || {};
const useState = React.useState;

window.NationalQueue.Student = ({student}) => {
  const [showModal, setShowModal] = useState(false);

  const openModal = () => {
    setShowModal(true);
  }

  return(
    <NationalQueue.QueueItem type='Student'>
      <NationalQueue.StudentInfo student={student} when={student.lastAssistedAt} showDetails={true} />

      <div className="actions float-right">
        <button className="btn btn-sm btn-light btn-main" onClick={openModal}>Assistance / Note</button>
      </div>

      {showModal && <NationalQueue.AssistanceModal hide={()=> setShowModal(false)}student={student} />}
    </NationalQueue.QueueItem>
  )
}