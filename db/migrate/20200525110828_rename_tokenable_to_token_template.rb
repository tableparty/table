class RenameTokenableToTokenTemplate < ActiveRecord::Migration[6.0]
  def up
    rename_column :tokens, :tokenable_id, :token_template_id
    remove_column :tokens, :tokenable_type
  end

  def down
    rename_column :tokens, :token_template_id, :tokenable_id
    add_column :tokens, :tokenable_type, :string

    execute <<~SQL
      UPDATE tokens
      SET tokenable_type='Character'
      WHERE tokenable_id IN (
        SELECT id FROM token_templates WHERE type='Character'
      );
    SQL

    execute <<~SQL
      UPDATE tokens
      SET tokenable_type='Creature'
      WHERE tokenable_id IN (
        SELECT id FROM token_templates WHERE type='Creature'
      );
    SQL
  end
end
