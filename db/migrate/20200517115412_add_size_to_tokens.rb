class AddSizeToTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :creatures, :size, :string, null: false, default: "medium"
    add_column :tokens, :size, :string, null: true
    add_column :characters, :size, :string, null: false, default: "medium"
  end
end
