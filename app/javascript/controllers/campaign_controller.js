import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["mapOption", "currentMap", "statusIndicator", "mapSelector"]

  connect() {
    this.campaignId = this.element.dataset.campaignId
    this.channel = consumer.subscriptions.create({
      channel: "CampaignChannel",
      id: this.campaignId
    }, {
      received: this.cableReceived.bind(this),
      connected: () => { this.statusIndicatorTarget.style.display = 'none' },
      disconnected: () => { this.statusIndicatorTarget.style.display = 'block' }
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
    this.mapSelectorTarget.dispatchEvent(new CustomEvent('toggle'))
  }

  cableReceived(data) {
    if (data.current_map_html) {
      this.currentMapTarget.innerHTML = data.current_map_html
    } else if (data.map_selector_html) {
      this.mapSelectorTarget.outerHTML = data.map_selector_html
    }
  }
}
