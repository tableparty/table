class RemoveGridSizeDefault < ActiveRecord::Migration[6.0]
  def change
    change_column_default :maps, :grid_size, from: 43, to: nil
  end
end
