class CreateMaps < ActiveRecord::Migration[6.0]
  def change
    create_table :maps, id: :uuid do |t|
      t.belongs_to :campaign, type: :uuid, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
