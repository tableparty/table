import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["mapName", "mapImage", "map"]

  connect() {
    const campaignId = this.element.dataset.id
    const maps = this.mapTargets
    const mapName = this.mapNameTarget
    const mapImage = this.mapImageTarget
    consumer.subscriptions.create({
      channel: "CampaignChannel",
      id: campaignId
    }, {
      received(data) {
        mapName.innerHTML = data.current_map.name
        mapImage.src = data.current_map_image
      },
      connected() {
        const changeMap = map => {
          this.perform("change_current_map", { map_id: map.dataset.mapId, campaign_id: campaignId })
        }
        maps.forEach(map => {
          map.addEventListener("click", () => changeMap(map))
        })
      }
    })
  }
}
