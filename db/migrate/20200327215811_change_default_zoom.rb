class ChangeDefaultZoom < ActiveRecord::Migration[6.0]
  def change
    change_column_default :maps, :zoom, from: 2, to: 0
  end
end
