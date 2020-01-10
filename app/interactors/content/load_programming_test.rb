class Content::LoadProgrammingTest

  include Interactor

  before do
    @log     = context.log
    @repo    = context.repo
    @data    = context.data
    @records = context.records
  end

  def call
    d = @data
    uuid = d['uuid']
    abort("\n\n---\nHALT! Test UUID required") if uuid.blank?
    abort("\n\n---\nHALT! Tests need an exam_code! investigate activity with this uuid #{d['uuid']}") if d['exam_code'].nil?

    programming_test = ProgrammingTest.find_or_initialize_by(uuid: uuid, exam_code: d['exam_code'])
    programming_test.assign_attributes(name: d['name'], day: d['day'])

    @records.push programming_test
    context.programming_test = programming_test
  end

end
