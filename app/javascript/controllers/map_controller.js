import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["image", "zoomIn", "zoomOut", "token"]

  connect() {
    this.speedFactor = 2
    this.mapId = this.element.dataset.mapId

    this.setViewportSize()
    this.disableZoomButtons()

    this.tokenTargets.forEach(target => {
      target.ondragstart = () => null
    })

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

  startMove(event) {
    event.stopPropagation()

    const { screenX, screenY, target } = event

    target.dataset.originalX = target.dataset.x
    target.dataset.originalY = target.dataset.y
    target.dataset.dragStartX = screenX
    target.dataset.dragStartY = screenY
    target.dataset.beingDragged = true
  }

  moveElement(event, scaleFactor) {
    event.stopPropagation()
    const { screenX, screenY, target } = event
    const { originalX, originalY, dragStartX, dragStartY, beingDragged } = target.dataset

    if (!beingDragged) {
      return false
    }

    target.dataset.x = parseInt(originalX) - ((parseInt(dragStartX) - screenX) * scaleFactor)
    target.dataset.y = parseInt(originalY) - ((parseInt(dragStartY) - screenY) * scaleFactor)

    return true
  }

  moveMap(event) {
    if (this.moveElement(event, this.speedFactor * -1)) {
      this.channel.perform(
        "move_map",
        {
          map_id: this.mapId,
          x: this.imageTarget.dataset.x,
          y: this.imageTarget.dataset.y
        }
      )
    }
  }

  moveToken(event) {
    const { zoomAmount } = this.imageTarget.dataset
    const { target } = event
    const { tokenId } = target.dataset

    if (this.moveElement(event, 1.0 / parseFloat(zoomAmount))) {
      this.channel.perform(
        "move_token",
        {
          map_id: this.mapId,
          token_id: tokenId,
          x: target.dataset.x,
          y: target.dataset.y
        }
      )
    }
  }

  finishMove({ target }) {
    delete target.dataset.originalX
    delete target.dataset.originalY
    delete target.dataset.dragStartX
    delete target.dataset.dragStartY
    delete target.dataset.beingDragged
  }

  zoomIn(event) {
    event.preventDefault()
    this.channel.perform(
      "set_zoom",
      {
        map_id: this.mapId,
        zoom: parseInt(this.imageTarget.dataset.zoom) + 1
      }
    )
  }

  zoomOut(event) {
    event.preventDefault()
    this.channel.perform(
      "set_zoom",
      {
        map_id: this.mapId,
        zoom: parseInt(this.imageTarget.dataset.zoom) - 1
      }
    )
  }

  setMapZoom(zoom, amount, width, height) {
    this.imageTarget.dataset.zoom = zoom
    this.imageTarget.dataset.width = width
    this.imageTarget.dataset.height = height
    this.imageTarget.dataset.zoomAmount = amount
    this.disableZoomButtons()
  }

  disableZoomButtons() {
    const zoom = parseInt(this.imageTarget.dataset.zoom)
    this.zoomOutTarget.disabled = (zoom === 0)
    this.zoomInTarget.disabled = (zoom === parseInt(this.imageTarget.dataset.zoomMax))
  }

  cableReceived(data) {
    switch (data.operation) {
      case "move": {
        if (this.imageTarget.dataset.beingDragged) {
          return
        }
        this.setMapPosition(data.x, data.y)
        break
      }
      case "zoom": {
        this.setMapPosition(data.x, data.y)
        this.setMapZoom(data.zoom, data.zoomAmount, data.width, data.height)
        break
      }
      case "moveToken": {
        const token = this.tokenTargets.find(token => token.dataset.tokenId == data.token_id)
        if (token.dataset.beingDragged) {
          return
        }
        this.setTokenPosition(token, data.x, data.y)
        break
      }
    }
  }

  setMapPosition(x, y) {
    this.imageTarget.dataset.x = x
    this.imageTarget.dataset.y = y
  }

  setViewportSize() {
    this.imageTarget.dataset.viewportX = this.imageTarget.clientWidth
    this.imageTarget.dataset.viewportY = this.imageTarget.clientHeight
  }

  setTokenPosition(token, x, y) {
    token.dataset.x = x
    token.dataset.y = y
  }

  setMapZoom(zoom, amount, width, height) {
    this.imageTarget.dataset.zoom = zoom
    this.imageTarget.dataset.zoomAmount = parseFloat(amount)
    this.imageTarget.dataset.width = width
    this.imageTarget.dataset.height = height
    this.imageTarget.dataset.zoomAmount = amount
    this.zoomOutTarget.disabled = (zoom === 0)
    this.zoomInTarget.disabled = (zoom === parseInt(this.imageTarget.dataset.zoomMax))
  }
}
