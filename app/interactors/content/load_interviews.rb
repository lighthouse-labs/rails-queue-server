class Content::LoadInterviews

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
    @repo_dir = context.repo_dir
    @records  = context.records

    @log.info "LOADING/BUILDING TECH INTERVIEW RECORDS"
  end

  def call
    interview_data = load_all_interview_data
    Content::ValidateUuids.call(collection: interview_data)
    build_records(interview_data)
  end

  private

  def load_all_interview_data
    interview_data = []

    data_dir = '_Interviews'
    dir = File.join(@repo_dir, data_dir)

    seq = 1
    Dir.entries(dir).sort.each do |content_file|
      next if content_file.starts_with?('.')
      next unless content_file.ends_with?('.md')
      interview_data.push extract_interview_file_data(@repo_dir, data_dir, content_file, seq)
      seq += 1
    end

    interview_data
  end

  def extract_interview_file_data(repo_dir, data_dir, filename, _sequence)
    content = File.open(File.join(repo_dir, data_dir, filename)).read
    attrs = extract_attributes(content)
    filename_parts = filename.split('__')
    attrs['file_path'] = File.join('data', data_dir, filename).to_s

    attrs
  end

  # returns an array containing:
  def extract_attributes(content)
    attrs = extract_frontmatter_attributes(content)
    attrs['markdown'] = content.lstrip.sub(/^---(.*?)---/m, "")
    attrs
  end

  def extract_frontmatter_attributes(content)
    attrs = {}
    if matches = content.lstrip.match(/^---(.*?)---.*/m)
      attrs = YAML.safe_load(matches[1])
    end
    attrs
  end

  def build_records(items)
    items.each do |data|
      @records.push build_interview(data)
      # @questions built by build_interview, and need to be added AFTER interview (parent is)
      @questions.each do |q|
        @records.push q
      end
    end
    nil
  end

  def build_interview(attributes)
    uuid = attributes.delete 'uuid'

    attrs = {
      week:               attributes['week'],
      content_file_path:  attributes['file_path'],
      content_repository: @repo
    }

    attrs.merge!(split_description_and_teacher_notes(attributes))

    interview = TechInterviewTemplate.find_or_initialize_by(uuid: uuid)
    interview.assign_attributes(attrs)
    @questions = build_questions(interview, attributes['questions'])
    interview
  end

  def build_questions(interview, question_data)
    questions = []
    question_data.each_with_index do |d, i|
      uuid = d['uuid']
      abort("\n\n---\nHALT! Question UUID required") if uuid.blank?
      # abort("\n\n---\nHALT! Dupe Question UUID found. Check your data, as this is potentially disasterous!") if @question_uuids.include?(uuid)

      attrs = {
        uuid:     uuid,
        archived: d['archived'] || false,
        question: d['question'],
        answer:   d['answer'],
        notes:    d['notes'],
        sequence: i + 1
      }
      attrs[:outcome] = Outcome.find_by(uuid: d['outcome']) if d['outcome']

      question = find_or_build_question(interview, attrs)

      questions.push question
    end
    questions
  end

  def find_or_build_question(interview, attrs)
    question = interview.questions.detect { |q| q.uuid == attrs[:uuid] } ||
               TechInterviewQuestion.new
    question.assign_attributes(attrs.merge(tech_interview_template: interview))
    question
  end

  def split_description_and_teacher_notes(d)
    content = d['markdown']

    separated = content.split(/^#+\s*Teacher Notes\s*$/)

    # return hash with both attributes (latter may be nil)
    {
      description:   separated[0],
      teacher_notes: separated[1] ? separated[1].lstrip : nil
    }
  end

end
