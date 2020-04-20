window.NationalQueue = window.NationalQueue || {};
const useRef = React.useRef;

window.NationalQueue.Student = ({student}) => {
  const assistanceModalRef = useRef();

  const openModal = () => {
    assistanceModalRef.current.open();
  }

  return(
    <NationalQueue.QueueItem type='Student'>
      <NationalQueue.StudentInfo student={student} when={student.lastAssistedAt} showDetails={true} />

      <div className="actions float-right">
        <button className="btn btn-sm btn-light btn-main" onClick={openModal}>Assistance / Note</button>
      </div>

      {/* <NationalQueue.AssistanceModal student={student} ref={assistanceModalRef} /> */}
    </NationalQueue.QueueItem>
  )
}