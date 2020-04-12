module CampaignsHelper
  def dm?(campaign, output = nil)
    if signed_in? && campaign.user == current_user
      output.presence || true
    end
  end
end
