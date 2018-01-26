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

    db_items.each do |db_item|
      if not_in_repo_data(repo_uuids, db_item[:uuid])
        archived_object = model.find_by(id: db_item[:id])
        archived_object.archived = true
        context.fail!("Failed to Set Archive for #{model.name}, id: #{db_item[:id]}") unless archived_object.save
      end
    end
  end

  def not_in_repo_data(repo_uuids, uuid)
    !repo_uuids.include?(uuid)
  end

end
