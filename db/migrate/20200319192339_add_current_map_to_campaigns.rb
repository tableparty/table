class AddCurrentMapToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_reference :campaigns, :current_map, type: :uuid,
                                            foreign_key: { to_table: :maps }
  end
end
