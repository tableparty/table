import { Controller } from "stimulus"
import consumer from "../channels/consumer"
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = ["mapOption", "currentMap", "statusIndicator"]

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
  }

  cableReceived(data) {
    switch (data.operation) {
      case "change_current_map": {
        Rails.ajax({
          url: window.location.href,
          type: "get",
          success: data => {
            this.currentMapTarget.innerHTML = data.html
          }
        })
        break
      }
    }
  }
}
