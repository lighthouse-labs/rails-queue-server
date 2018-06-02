class Content::LoadWorkModule

  include Interactor

  before do
    @log      = context.log
    @repo     = context.repo
    @records  = context.records
    @data     = context.data
    @workbook = context.workbook
  end

  def call
    d = @data
    uuid = d['uuid']

    work_module = WorkModule.find_or_initialize_by(uuid: uuid)
    work_module.assign_attributes(build_attributes(d))
    work_module.order ||= 99

    @records.push work_module

    load_work_module_items(work_module, d)
  end

  private

  def load_work_module_items(work_module, data)
    items = data['items']

    items.each do |item_attributes|
      load_work_module_item(work_module, item_attributes)
    end
  end

  def load_work_module_item(work_module, item_data)
    activity = scan_for_record_by_uuid(item_data['activity'], Activity)

    if activity
      item = work_module.work_module_items.find_or_initialize_by(uuid: item_data['uuid'])
      item.activity = activity
      item.order = item_data['order']
      item.archived = item_data['archived']
      @records << item
    end
  end

  def scan_for_record_by_uuid(uuid, klass = nil)
    @records.detect { |r| r.uuid == uuid && (klass.nil? || r.is_a?(klass)) }
  end

  # There's intentionally no AR mass assignment
  #   it would be problematic from a maintenance workflow standpoint - KV
  def build_attributes(d)
    attrs = {
      workbook:           @workbook,
      name:               d['name'],
      slug:               d['slug'],
      archived:           d['archived'],
    }
    # if sequence is not specified, do not change the existing one
    attrs[:order] = d['order'] if d['order']
    attrs
  end

end
