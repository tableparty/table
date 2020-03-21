import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["mapOption", "currentMap"]

  connect() {
    this.campaignId = this.element.dataset.campaignId
    this.channel = consumer.subscriptions.create({
      channel: "CampaignChannel",
      id: this.campaignId
    }, {
      received: this.cableReceived.bind(this),
    })
  }

  chooseMapOption(event) {
    this.channel.perform(
      "change_current_map",
      {
        map_id: event.target.dataset.mapId,
        campaign_id: this.campaignId
      }
    )
  }

  cableReceived(data) {
    this.currentMapTarget.innerHTML = data.current_map_html
  }
}
