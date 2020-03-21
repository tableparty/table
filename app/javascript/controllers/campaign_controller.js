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
      connected: this.cableConnected.bind(this)
    })
  }

  cableReceived(data) {
    console.log(data)
    this.currentMapTarget.innerHTML = data.current_map_html
  }

  cableConnected() {
    const changeMap = map => {
      this.channel.perform(
        "change_current_map",
        { map_id: map.dataset.mapId, campaign_id: this.campaignId }
      )
    }
    this.mapOptionTargets.forEach(mapOption => {
      mapOption.addEventListener("click", () => changeMap(mapOption))
    })
  }
}
