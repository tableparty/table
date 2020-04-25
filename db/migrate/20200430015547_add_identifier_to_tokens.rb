class AddIdentifierToTokens < ActiveRecord::Migration[6.0]
  def change
    add_column :tokens, :identifier, :string
  end
end
