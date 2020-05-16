module ApplicationCable
  class Channel < ActionCable::Channel::Base
    protected

    def dm?(campaign)
      campaign.user == current_user
    end
  end
end
