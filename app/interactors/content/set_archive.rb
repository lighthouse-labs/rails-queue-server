class Content::SetArchive

  include Interactor

  def call
    set_archive(context.repo_data, context.model)
  end

  private

  def set_archive(repo_data, model)
    repo_uuids = []

    repo_data.each do |data|
      repo_uuids.push data['uuid']
    end

    db_items = model.where(archived: [nil, false]).map{ |m| {id: m.id, uuid: m.uuid} }

    archived_db_items = model.where(archived: true).map{ |m| {id: m.id, uuid: m.uuid} }

    db_items.each do |db_item|
      if !in_repo_data(repo_uuids, db_item[:uuid])
        archived_object = model.find_by(id: db_item[:id])
        archived_object.archived = true
        context.fail!("Failed to Set Archive for #{model.name}, id: #{db_item[:id]}") unless archived_object.save
      end
    end

    archived_db_items.each do |db_item|
      if in_repo_data(repo_uuids, db_item[:uuid])
        archived_object = model.find_by(id: db_item[:id])
        archived_object.archived = false
        context.fail!("Failed to Set Archive for #{model.name}, id: #{db_item[:id]}") unless archived_object.save
      end
    end
  end

  def in_repo_data(repo_uuids, db_uuid)
    repo_uuids.include?(db_uuid)
  end

end
