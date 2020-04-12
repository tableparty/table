module ApplicationCable
  class Channel < ActionCable::Channel::Base
    protected

    def render_partial(partial, options = {})
      ActionController::Renderer::RACK_KEY_TRANSLATION[:clearance] ||=
        :clearance
      clearance_session = Clearance::Session.new({}).tap do |session|
        session.sign_in(current_user)
      end
      ApplicationController.renderer.new(clearance: clearance_session).render(
        options.merge(partial: partial)
      )
    end

    def dm?(campaign)
      campaign.user == current_user
    end
  end
end
