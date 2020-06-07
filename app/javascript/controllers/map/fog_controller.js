import { Controller } from "stimulus"
import { v4 as uuid } from "uuid"
import consumer from "../../channels/consumer"

export default class extends Controller {
  static targets = ["image", "fogMask", "fogArea"]

  connect() {
    this.mapId = this.element.dataset.mapId

    this.channel = consumer.subscriptions.create({
      channel: "Maps::FogChannel",
      id: this.mapId
    }, {
      received: this.cableReceived.bind(this)
    })
  }

  disconnect() {
  }

  mapPositionOf(event) {
    const { clientX, clientY } = event
    const { viewportX, viewportY, x: mapX, y: mapY, zoomAmount } = this.imageTarget.dataset
    const { left: imageLeft, top: imageTop } = this.imageTarget.getBoundingClientRect()

    const x = Math.round((clientX - imageLeft) / parseFloat(zoomAmount) - (((parseFloat(viewportX) / 2) - parseFloat(mapX)) / parseFloat(zoomAmount)))
    const y = Math.round((clientY - imageTop) / parseFloat(zoomAmount) - (((parseFloat(viewportY) / 2) - parseFloat(mapY)) / parseFloat(zoomAmount)))
    return { x, y }
  }

  cableReceived(data) {
    switch (data.operation) {
      case "revealArea": {
        if (!this.fogAreaTargets.find(area => area.dataset.id == data.id)) {
          this.addFogArea(data.id, data.path)
        }
      }
    }
  }

  addFogArea(id, path) {
    const fogPath = document.createElementNS("http://www.w3.org/2000/svg", "path")
    fogPath.setAttribute("class", "fog__revealed")
    fogPath.setAttribute('d', path)
    fogPath.dataset.target = "map--fog.fogArea"
    fogPath.dataset.id = id
    this.fogMaskTarget.appendChild(fogPath)
    return fogPath
  }

  startDrawingFog(event) {
    if(event.shiftKey) {
      event.stopImmediatePropagation()
      const { x: startX, y: startY } = this.mapPositionOf(event)
      const fogPath = this.addFogArea(uuid(), `M ${startX} ${startY}`)

      const drawFog = event => {
        event.stopImmediatePropagation()
        const { x, y } = this.mapPositionOf(event)
        fogPath.setAttribute('d', `${fogPath.getAttribute('d')} L ${x} ${y}`)
      }
      document.onmouseup = event => {
        event.stopImmediatePropagation()
        fogPath.setAttribute('d', `${fogPath.getAttribute('d')} Z`)
        this.channel.perform(
          "reveal_area",
          {
            map_id: this.mapId,
            id: fogPath.dataset.id,
            path: fogPath.getAttribute("d")
          }
        )
        document.removeEventListener("mousemove", drawFog)
        document.onmouseup = null
      }
      document.addEventListener("mousemove", drawFog)
    }
  }
}
