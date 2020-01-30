class AddWorkbookIdToSections < ActiveRecord::Migration[5.0]
  def change
    add_reference :sections, :workbook, index: true, foreign_key: true
  end
end
