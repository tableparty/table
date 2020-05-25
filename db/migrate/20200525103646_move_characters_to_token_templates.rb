class MoveCharactersToTokenTemplates < ActiveRecord::Migration[6.0]
  def up
    execute <<~SQL
      INSERT INTO token_templates(
        id,
        type,
        campaign_id,
        name,
        size,
        created_at,
        updated_at
      )
      SELECT
        id,
        'Character' as type,
        campaign_id,
        name,
        size,
        created_at,
        updated_at
      FROM characters;
    SQL

    execute <<~SQL
      UPDATE active_storage_attachments
      SET record_type='TokenTemplate'
      WHERE record_type='Character';
    SQL

    execute "DELETE FROM characters;"

    drop_table :characters
  end

  def down
    create_table :characters, id: :uuid do |t|
      t.belongs_to :campaign, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :size, null: false, default: "medium"

      t.timestamps
    end

    execute <<~SQL
      INSERT INTO characters(
        id,
        campaign_id,
        name,
        size,
        created_at,
        updated_at
      )
      SELECT
        id,
        campaign_id,
        name,
        size,
        created_at,
        updated_at
      FROM token_templates
      WHERE type='Character';
    SQL

    execute <<~SQL
      UPDATE active_storage_attachments
      SET record_type='Character'
      WHERE record_type='TokenTemplate'
        AND record_id IN (SELECT id FROM characters);
    SQL

    execute "DELETE FROM token_templates WHERE type='Character';"
  end
end
