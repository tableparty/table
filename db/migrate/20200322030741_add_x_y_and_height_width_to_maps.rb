class AddXYAndHeightWidthToMaps < ActiveRecord::Migration[6.0]
  def change
    change_table(:maps) do |t|
      t.integer :x, :y, default: 0, null: false
      t.integer :width, :height
    end
  end
end
