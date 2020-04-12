class AddTokenableToTokens < ActiveRecord::Migration[6.0]
  def change
    change_table :tokens do |t|
      t.uuid :tokenable_id
      t.string :tokenable_type
      t.index %i[tokenable_type tokenable_id]
    end
  end
end
