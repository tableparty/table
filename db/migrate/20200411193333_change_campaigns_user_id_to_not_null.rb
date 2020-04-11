class ChangeCampaignsUserIdToNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :campaigns, :user_id, false
  end
end
