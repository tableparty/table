class BroadcastFogArea
  include Interactor

  def call
    Maps::FogChannel.reveal_area(context.fog_area)
  end
end
