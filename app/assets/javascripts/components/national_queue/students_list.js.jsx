window.Queue = window.Queue || {};
const useEffect = React.useEffect;
const useState = React.useState;


window.NationalQueue.StudentsList = ({user}) => {
  const [students, setStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const url = `/queue_tasks/students`
    // $.ajax({
    //   dataType: 'json',
    //   method: 'GET',
    //   url
    // }).done(resp => {
    //   console.log(resp);
    //   //get studnts 
    //   setStudents(resp.students);
    // }).always(() => {
    //   setLoading(false);
    // })
  }, []);

  const renderStudent = (student) => {
    return <NationalQueue.Student key={`student-${student.id}`} student={student} />
  }

  const renderStudents = () => {
    return students.map(renderStudent);
  }

  return (
    <NationalQueue.ListGroup count={students.length} title="Students">
      { renderStudents() }
    </NationalQueue.ListGroup>
  );
}

