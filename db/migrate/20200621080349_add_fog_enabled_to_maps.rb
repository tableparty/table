class AddFogEnabledToMaps < ActiveRecord::Migration[6.0]
  def change
    add_column :maps, :fog_enabled, :boolean, null: false, default: false
  end
end
