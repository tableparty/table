import { Controller } from "stimulus"
import consumer from "../../channels/consumer"

export default class extends Controller {
  static targets = ["container", "image"]

  connect() {
    this.mapId = this.element.dataset.mapId

    this.channel = consumer.subscriptions.create({
      channel: "Maps::PointersChannel",
      id: this.mapId
    }, {
      received: this.cableReceived.bind(this)
    })
  }

  cableReceived(data) {
    switch (data.operation) {
      case "addPointer": {
        this.containerTarget.insertAdjacentHTML("beforeend", data.pointer_html)
        break;
      }
    }
  }

  pointTo(event) {
    if (event.altKey) {
      event.preventDefault()
      event.stopPropagation()

      const { x, y } = this.mapPositionOf(event)

      this.channel.perform(
        "point_to",
        {
          map_id: this.mapId,
          x, y
        }
      )
    }
  }

  mapPositionOf(event) {
    const { clientX, clientY } = event
    const { viewportX, viewportY, x: mapX, y: mapY, zoomAmount } = this.imageTarget.dataset
    const { left: imageLeft, top: imageTop } = this.imageTarget.getBoundingClientRect()

    const x = Math.round((clientX - imageLeft) / parseFloat(zoomAmount) - (((parseFloat(viewportX) / 2)) / parseFloat(zoomAmount)) + parseFloat(mapX))
    const y = Math.round((clientY - imageTop) / parseFloat(zoomAmount) - (((parseFloat(viewportY) / 2)) / parseFloat(zoomAmount)) + parseFloat(mapY))
    return { x, y }
  }
}
