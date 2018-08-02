class RemovePresenterNameFromLectures < ActiveRecord::Migration[5.0]
  def change
    remove_column :lectures, :presenter_name, :string
  end
end
