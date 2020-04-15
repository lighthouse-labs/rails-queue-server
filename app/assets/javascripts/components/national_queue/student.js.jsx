window.NationalQueue = window.NationalQueue || {};
const useRef = React.useRef;

window.NationalQueue.Student = ({student}) => {
  const requestModalRef = useRef();

  const openModal = () => {
    requestModalRef.current.open();
  }

  return(
    <NationalQueue.QueueItem type='Student'>
      <NationalQueue.StudentInfo student={student} when={student.lastAssistedAt} showDetails={true} />

      <div className="actions float-right">
        <button className="btn btn-sm btn-light btn-main" onClick={openModal}>Assistance / Note</button>
      </div>

      {/* <NationalQueue.RequestModal student={student} ref={requestModalRef} /> */}
    </NationalQueue.QueueItem>
  )
}