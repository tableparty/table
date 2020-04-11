import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["image", "zoomIn", "zoomOut", "token"]

  connect() {
    this.mapId = this.element.dataset.mapId

    this.setViewportSize()

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

  moveMap(event) {
    const speedFactor = 2
    const mousedown = {
      x: event.screenX,
      y: event.screenY
    }
    const original = {
      x: parseInt(this.imageTarget.dataset.x),
      y: parseInt(this.imageTarget.dataset.y),
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

  startMoveToken(event) {
    event.stopPropagation()
    const { screenX, screenY, target } = event
    target.dataset.originalX = target.dataset.x
    target.dataset.originalY = target.dataset.y
    target.dataset.dragStartX = screenX
    target.dataset.dragStartY = screenY
    target.dataset.beingDragged = true

    const moveToken = this.buildMoveToken(target).bind(this)

    document.addEventListener("mousemove", moveToken)
    document.addEventListener("mouseup", () => {
      target.dataset.beingDragged = false
      document.removeEventListener("mousemove", moveToken)
      delete target.dataset.originalX
      delete target.dataset.originalY
      delete target.dataset.dragStartX
      delete target.dataset.dragStartY
      delete target.dataset.beingDragged
    })
  }

  buildMoveToken(target) {
    return event => {
      const { screenX, screenY } = event
      const { originalX, originalY, dragStartX, dragStartY, tokenId } = target.dataset
      const { zoomAmount } = this.imageTarget.dataset

      this.setTokenLocation(
        target,
        parseInt(originalX) + ((screenX - parseInt(dragStartX)) / parseFloat(zoomAmount)),
        parseInt(originalY) + ((screenY - parseInt(dragStartY)) / parseFloat(zoomAmount))
      )

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

  setMapZoom(zoom, amount, width, height) {
    this.imageTarget.dataset.zoom = zoom
    this.imageTarget.dataset.zoomAmount = parseFloat(amount)
    this.imageTarget.dataset.width = width
    this.imageTarget.dataset.height = height
    this.imageTarget.dataset.zoomAmount = amount
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
        this.setTokenLocation(token, data.x, data.y)
        break
      }
    }
  }

  setTokenLocation(token, x, y) {
    token.dataset.x = x
    token.dataset.y = y
  }
}
