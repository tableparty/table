import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["image", "zoomIn", "zoomOut", "fogMask", "fogArea", "tokenContainer"]

  connect() {
    this.mapId = this.element.dataset.mapId
    this.zoomAmounts = this.imageTarget.dataset.zoomAmounts.split(",").map(parseFloat)

    this.setViewportSize()
    this.updateZoomButtons()

    this.channel = consumer.subscriptions.create({
      channel: "MapChannel",
      id: this.mapId
    }, {
      received: this.cableReceived.bind(this)
    })

    this.onWindowResize = this.setViewportSize.bind(this)
    window.addEventListener('resize', this.onWindowResize)
  }

  disconnect() {
    window.removeEventListener('resize', this.onWindowResize)
  }

  mapPositionOf(event) {
    const { clientX, clientY } = event
    const { viewportX, viewportY, x: mapX, y: mapY, zoomAmount } = this.imageTarget.dataset
    const { left: imageLeft, top: imageTop } = this.imageTarget.getBoundingClientRect()

    const x = Math.round((clientX - imageLeft) / parseFloat(zoomAmount) - (((parseFloat(viewportX) / 2)) / parseFloat(zoomAmount)) + parseFloat(mapX))
    const y = Math.round((clientY - imageTop) / parseFloat(zoomAmount) - (((parseFloat(viewportY) / 2)) / parseFloat(zoomAmount)) + parseFloat(mapY))
    return { x, y }
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

  moveMap(event) {
    const speedFactor = 2
    const mousedown = {
      x: event.screenX,
      y: event.screenY
    }
    const original = {
      x: parseFloat(this.imageTarget.dataset.x),
      y: parseFloat(this.imageTarget.dataset.y),
    }
    const handleMove = (event) => {
      this.imageTarget.dataset.beingDragged = true
      const mousepos = {
        x: event.screenX,
        y: event.screenY
      }
      if (mousedown != mousepos) {
        this.setMapPosition(
          original.x - ((mousepos.x - mousedown.x) * speedFactor),
          original.y - ((mousepos.y - mousedown.y) * speedFactor)
        )
      }
    }
    document.addEventListener("mouseup", () => {
      delete this.imageTarget.dataset.beingDragged
      document.removeEventListener("mousemove", handleMove)
    })
    document.addEventListener("mousemove", handleMove)
  }

  setMapPosition(x, y) {
    this.imageTarget.dataset.x = x
    this.imageTarget.dataset.y = y
  }

  setViewportSize() {
    this.imageTarget.dataset.viewportX = this.imageTarget.clientWidth
    this.imageTarget.dataset.viewportY = this.imageTarget.clientHeight
  }

  zoomIn(event) {
    event.preventDefault()

    const zoom = parseInt(this.imageTarget.dataset.zoom) + 1
    this.setMapZoom(zoom)
  }

  zoomOut(event) {
    event.preventDefault()

    const zoom = parseInt(this.imageTarget.dataset.zoom) - 1
    this.setMapZoom(zoom)
  }

  setMapZoom(zoom) {
    if (zoom < 0 || zoom >= this.zoomAmounts.length) {
      return
    }

    const zoomAmount = this.zoomAmounts[zoom]
    this.imageTarget.dataset.zoom = zoom
    this.imageTarget.dataset.zoomAmount = zoomAmount
    this.updateZoomButtons()

    this.channel.perform(
      "set_zoom",
      {
        map_id: this.mapId,
        zoom
      }
    )
  }

  updateZoomButtons() {
    if (this.hasZoomOutTarget && this.hasZoomInTarget) {
      const zoom = parseInt(this.imageTarget.dataset.zoom)
      this.zoomOutTarget.disabled = (zoom === 0)
      this.zoomInTarget.disabled = (zoom === parseInt(this.imageTarget.dataset.zoomMax))
    }
  }

  cableReceived(data) {
    switch (data.operation) {
      case "addPointer": {
        this.tokenContainerTarget.insertAdjacentHTML("beforeend", data.pointer_html)
        break;
      }
    }
  }
}
