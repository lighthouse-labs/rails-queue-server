class Content::SetArchive

  include Interactor

  before do
    @repo_data = context.repo_data
    @model = context.model
  end

  def call
    get_repo_uuids
    get_db_items
    set_archive
  end

  private

  def get_repo_uuids
    @repo_uuids = []
    @repo_data.each do |data|
      @repo_uuids.push data['uuid']
    end
  end

  def get_db_items
    @db_items = @model.where(archived: [nil, false]).map{ |m| {id: m.id, uuid: m.uuid} }
    @archived_db_items = @model.where(archived: true).map{ |m| {id: m.id, uuid: m.uuid} }
  end

  def set_archive
    @db_items.each do |db_item|
      if !in_curric_repo_data(db_item[:uuid])
        archived_object = @model.find_by(id: db_item[:id])
        archived_object.archived = true
        context.fail!("Failed to Set Archive for #{@model.name}, id: #{db_item[:id]}") unless archived_object.save
      end
    end

    @archived_db_items.each do |db_item|
      if in_curric_repo_data(db_item[:uuid])
        archived_object = @model.find_by(id: db_item[:id])
        archived_object.archived = false
        context.fail!("Failed to Set Archive for #{@model.name}, id: #{db_item[:id]}") unless archived_object.save
      end
    end
  end

  def in_curric_repo_data(db_uuid)
    @repo_uuids.include?(db_uuid)
  end

end
