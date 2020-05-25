class AddTokenTemplate < ActiveRecord::Migration[6.0]
  def change
    create_table :token_templates, id: :uuid do |t|
      t.string :type, null: false
      t.belongs_to :campaign, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :size, default: "medium", null: false

      t.timestamps
    end
  end
end
