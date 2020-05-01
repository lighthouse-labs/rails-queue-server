class AddWorkbookIdToLectures < ActiveRecord::Migration[5.0]
  def change
    add_reference :lectures, :workbook, foreign_key: true
  end
end
