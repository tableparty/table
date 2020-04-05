class AddZoomToMaps < ActiveRecord::Migration[6.0]
  def change
    remove_column :maps, :height, :integer # rubocop:disable Rails/BulkChangeTable
    remove_column :maps, :width, :integer
    add_column :maps, :zoom, :integer, null: false, default: 2
  end
end
