class ContentReposBelongToProgramsDuh < ActiveRecord::Migration[5.0]
  def up
    add_reference :content_repositories, :program

    if p_id = Program.first.id
      ContentRepository.update_all(program_id: p_id)
    end
  end

  def down
    remove_column :content_repositories, :program_id
  end
end
