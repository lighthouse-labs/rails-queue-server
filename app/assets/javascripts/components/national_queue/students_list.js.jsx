window.Queue = window.Queue || {};
const useEffect = React.useEffect;
const useState = React.useState;

window.NationalQueue.StudentsList = ({user, setOpen, open, updates}) => {
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const {studentsWithUpdates} = window.NationalQueue.QueueSelectors;

  useEffect(() => {
    const url = `/queue_tasks/students`
    $.ajax({
      dataType: 'json',
      method: 'GET',
      url
    }).done(resp => {
      setStudents(resp.students);
    }).always(() => {
      setLoading(false);
    })
  }, []);

  const renderStudent = (student) => {
    return <NationalQueue.Student key={`student-${student.id}`} student={student} />
  }

  const renderStudents = () => {
    // const updatedStudents = studentsWithUpdates(students, updates);
    return students.map(renderStudent);
  }

  return (
    <NationalQueue.ListGroup open={open} toggleOpen={()=>setOpen(!open)} count={students.length} title="Students">
      { renderStudents() }
    </NationalQueue.ListGroup>
  )
}
