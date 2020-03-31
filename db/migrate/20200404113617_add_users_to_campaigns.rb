class AddUsersToCampaigns < ActiveRecord::Migration[6.0]
  def change
    add_belongs_to :campaigns, :user, type: :uuid, null: true, foreign_key: true
  end
end
