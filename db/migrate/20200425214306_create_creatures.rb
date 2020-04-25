class CreateCreatures < ActiveRecord::Migration[6.0]
  def change
    create_table :creatures, id: :uuid do |t|
      t.belongs_to :campaign, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false

      t.timestamps
    end
  end
end
