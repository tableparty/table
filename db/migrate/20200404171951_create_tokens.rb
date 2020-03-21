class CreateTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :tokens, id: :uuid do |t|
      t.belongs_to :map, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.integer :x
      t.integer :y

      t.timestamps
    end
  end
end
