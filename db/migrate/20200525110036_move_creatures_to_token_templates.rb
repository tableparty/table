class MoveCreaturesToTokenTemplates < ActiveRecord::Migration[6.0]
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
        'Creature' as type,
        campaign_id,
        name,
        size,
        created_at,
        updated_at
      FROM creatures;
    SQL

    execute <<~SQL
      UPDATE active_storage_attachments
      SET record_type='TokenTemplate'
      WHERE record_type='Creature';
    SQL

    execute "DELETE FROM creatures;"

    drop_table :creatures
  end

  def down
    create_table :creatures, id: :uuid do |t|
      t.belongs_to :campaign, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :size, null: false, default: "medium"

      t.timestamps
    end

    execute <<~SQL
      INSERT INTO creatures(
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
      WHERE type='Creature';
    SQL

    execute <<~SQL
      UPDATE active_storage_attachments
      SET record_type='Creature'
      WHERE record_type='TokenTemplate'
        AND record_id IN (SELECT id FROM creatures);
    SQL

    execute "DELETE FROM token_templates WHERE type='Creature';"
  end
end
