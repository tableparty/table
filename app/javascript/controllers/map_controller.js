import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["image", "zoomIn", "zoomOut", "token", "tokenContainer", "tokenDrawer"]

  connect() {
    this.mapId = this.element.dataset.mapId

    this.setViewportSize()
    this.updateZoomButtons()

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

  mapPositionOf(event) {
    const { clientX, clientY } = event
    const { viewportX, viewportY, x: mapX, y: mapY, zoomAmount } = this.imageTarget.dataset
    const { left: imageLeft, top: imageTop } = this.imageTarget.getBoundingClientRect()

    const x = Math.round((clientX - imageLeft) / parseFloat(zoomAmount) - (((parseFloat(viewportX) / 2) - parseFloat(mapX)) / parseFloat(zoomAmount)))
    const y = Math.round((clientY - imageTop) / parseFloat(zoomAmount) - (((parseFloat(viewportY) / 2) - parseFloat(mapY)) / parseFloat(zoomAmount)))
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

  stopPropagation(event) {
    event.stopPropagation()
  }

  startMoveToken(event) {
    event.stopPropagation()

    const { target, clientX, clientY } = event
    const { left, top } = target.getBoundingClientRect()

    const tokenImage = target.getElementsByClassName("token__image")[0]
    const { width: tokenWidth, height: tokenHeight } = tokenImage.getBoundingClientRect()

    target.dataset.beingDragged = true
    target.dataset.offsetX = (tokenWidth / 2) - (clientX - left)
    target.dataset.offsetY = (tokenHeight / 2) - (clientY - top)

    event.dataTransfer.setData("text/plain", target.dataset.tokenId)
  }

  moveToken(event) {
    event.stopPropagation()

    const { target } = event
    const { x: currentX, y: currentY, offsetX, offsetY, tokenId } = target.dataset
    const { zoomAmount } = this.imageTarget.dataset


    const { x, y } = this.mapPositionOf(event)

    const newX = Math.floor(x + (parseFloat(offsetX) / parseFloat(zoomAmount)))
    const newY = Math.floor(y + (parseFloat(offsetY) / parseFloat(zoomAmount)))

    if (newX != currentX || newY != currentY) {
      this.setTokenLocation(
        target,
        newX,
        newY
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

  endMoveToken({ target }) {
    delete target.dataset.beingDragged
    delete target.dataset.offsetX
    delete target.dataset.offsetY
  }

  setMapZoom(zoom, amount, width, height) {
    this.imageTarget.dataset.zoom = zoom
    this.imageTarget.dataset.width = width
    this.imageTarget.dataset.height = height
    this.imageTarget.dataset.zoomAmount = amount
    this.updateZoomButtons()
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
        const token = this.findToken(data.token_id)
        if (token.dataset.beingDragged) {
          return
        }
        this.setTokenLocation(token, data.x, data.y)
        break
      }
      case "addToken": {
        if (this.findToken(data.token_id)) {
          return
        }
        this.tokenContainerTarget.insertAdjacentHTML("beforeend", data.token_html);
        const token = this.findToken(data.token_id)
        if (data.stashed) {
          if (this.hasTokenDrawerTarget) {
            this.tokenDrawerTarget.appendChild(token)
          } else {
            token.remove()
          }
        }
        break;
      }
      case "addPointer": {
        this.tokenContainerTarget.insertAdjacentHTML("beforeend", data.pointer_html)
        break;
      }
      case "stashToken": {
        const token = this.findToken(data.token_id)
        if (this.hasTokenDrawerTarget) {
          this.tokenDrawerTarget.appendChild(token)
        } else {
          token.remove()
        }
        break
      }
    }
  }

  findToken(tokenId) {
    return this.tokenTargets.find(token => token.dataset.tokenId == tokenId)
  }

  setTokenLocation(token, x, y) {
    token.dataset.x = x
    token.dataset.y = y
  }

  dragOverDrawer(event) {
    event.preventDefault()
  }

  dropOnDrawer(event) {
    event.preventDefault()
    const tokenId = event.dataTransfer.getData("text/plain")

    const token = this.findToken(tokenId)
    this.tokenDrawerTarget.appendChild(token)

    this.channel.perform(
      "stash_token",
      {
        map_id: this.mapId,
        token_id: tokenId
      }
    )
  }

  dragOverMap(event) {
    event.preventDefault()
  }

  dropOnMap(event) {
    event.preventDefault()
    const tokenId = event.dataTransfer.getData("text/plain")

    const token = this.findToken(tokenId)
    if (token.parentNode != this.tokenContainerTarget) {
      if (token.dataset.copyOnPlace != "true") {
        this.tokenContainerTarget.appendChild(token)
      }

      this.channel.perform(
        "place_token",
        {
          map_id: this.mapId,
          token_id: tokenId
        }
      )
    }
  }
}
