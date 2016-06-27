class AddContentRepositoryIdToSections < ActiveRecord::Migration
  def change
    add_reference :sections, :content_repository, index: true, foreign_key: true
  end
end
