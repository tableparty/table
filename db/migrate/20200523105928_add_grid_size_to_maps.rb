class AddGridSizeToMaps < ActiveRecord::Migration[6.0]
  def change
    add_column :maps, :grid_size, :integer, default: 43, null: false
  end
end
