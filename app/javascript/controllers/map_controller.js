import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["image", "zoomIn", "zoomOut", "token"]

  connect() {
    this.mapId = this.element.dataset.mapId

    this.observer = new MutationObserver(mutations => {
      mutations.forEach(({ target, attributeName }) => {
        target.dataset.cssVars.split(" ").forEach(cssVar => {
          if (attributeName == `data-${cssVar}`) {
            target.style.setProperty(`--${cssVar}`, target.dataset[cssVar])
          }
        })
      })
    })

    this.observer.observe(this.element, { attributes: true })
    this.tokenTargets.forEach(token => this.observer.observe(token, { attributes: true }))

    this.setViewportSize()
    this.setMapPosition(
      parseInt(this.element.dataset.x),
      parseInt(this.element.dataset.y)
    )
    this.setMapZoom(
      parseInt(this.element.dataset.zoom),
      parseFloat(this.element.dataset.zoomAmount),
      parseInt(this.element.dataset.width),
      parseInt(this.element.dataset.height)
    )

    this.tokenTargets.forEach(target => {
      target.ondragstart = () => { return null }
      this.setTokenLocation(target, target.dataset.x, target.dataset.y)
    })

    this.channel = consumer.subscriptions.create({
      channel: "MapChannel",
      id: this.mapId
    }, {
      received: this.cableReceived.bind(this)
    })

    this.repositionMap = () => {
      this.setMapPosition(
        this.imageTarget.dataset.x,
        this.imageTarget.dataset.y
      )
    }

    window.addEventListener('resize', this.repositionMap)
  }

  disconnect() {
    window.removeEventListener('resize', this.repositionMap)
    this.observer.disconnect()
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
      this.imageTarget.dataset.beingDragged = false
      document.removeEventListener("mousemove", handleMove)
    })
    document.addEventListener("mousemove", handleMove)
  }

  setMapPosition(x, y) {
    this.imageTarget.dataset.x = x
    this.imageTarget.dataset.y = y
  }

  setViewportSize() {
    let viewportX = this.imageTarget.clientWidth / 2
    let viewportY = this.imageTarget.clientHeight / 2
    this.imageTarget.dataset.viewportX = viewportX
    this.imageTarget.dataset.viewportY = viewportY
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
        if (token.dataset.beingDragged == "true") {
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
