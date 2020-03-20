import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["mapName", "mapImage", "map"]

  connect() {
    this.campaignId = this.element.dataset.id
    this.channel = consumer.subscriptions.create({
      channel: "CampaignChannel",
      id: this.campaignId
    }, {
      received: this.cableReceived.bind(this),
      connected: this.cableConnected.bind(this)
    })
  }

  cableReceived(data) {
    this.mapNameTarget.innerHTML = data.current_map.name
    this.mapImageTarget.src = data.current_map_image
  }

  cableConnected() {
    const changeMap = map => {
      this.channel.perform("change_current_map", { map_id: map.dataset.mapId, campaign_id: this.campaignId })
    }
    this.mapTargets.forEach(map => {
      map.addEventListener("click", () => changeMap(map))
    })
  }
}
