class CreateFogAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :fog_areas, id: :uuid do |t|
      t.belongs_to :map, null: false, foreign_key: true, type: :uuid
      t.string :path, null: false

      t.timestamps
    end
  end
end
