class Content::SetArchive

  include Interactor

  def call
    set_archive(context.repo_data, context.model)
  end

  def set_archive(repo_data, model)
    repo_uuids = []

    repo_data.each do |data|
      repo_uuids.push data['uuid']
    end

    database_uuids = model.where(archived: [nil, false]).map{ |m| [m.id, m.uuid] }

    database_uuids.each do |db|
      if !repo_uuids.include?(db[1])
        archived_object = model.find_by(id: db[0])
        archived_object.archived = true
        context.fail!("Failed to Set Archive for #{model.name}, id: #{db[0]}") if !archived_object.save
      end
    end
  end
end
