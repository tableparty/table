import { Controller } from "stimulus"
import { v4 as uuid } from "uuid"
import consumer from "../../channels/consumer"

export default class extends Controller {
  static targets = ["image", "canvas"]

  connect() {
    this.mapId = this.element.dataset.mapId

    this.channel = consumer.subscriptions.create({
      channel: "Maps::FogChannel",
      id: this.mapId
    }, {
      received: this.cableReceived.bind(this)
    })

    this.drawCanvas()
  }

  drawCanvas() {
    const fogAreas = this.fogAreas
    let stillAnimating = false

    const ctx = this.canvasTarget.getContext('2d')
    ctx.globalCompositeOperation = "source-over"
    ctx.fillRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
    ctx.globalCompositeOperation = "destination-out"

    fogAreas.forEach(area => {
      const fadeDuration = 1000.0
      const addedAt = area.addedAt || 0
      const timeDiff = (fadeDuration - Math.min((Date.now() - addedAt), fadeDuration)) / fadeDuration
      if (timeDiff > 0.0 && !stillAnimating) {
        stillAnimating = true
      }
      ctx.fillStyle = `rgba(0, 0, 0, ${1.0 - timeDiff})`

      ctx.beginPath()
      for(const { x, y } of area.path) {
        ctx.lineTo(x, y)
      }
      ctx.fill()
      ctx.closePath()
    })

    if (stillAnimating) {
      window.requestAnimationFrame(this.drawCanvas.bind(this))
    }
  }

  disconnect() {
  }

  mapPositionOf(event) {
    const { clientX, clientY } = event
    const { viewportX, viewportY, x: mapX, y: mapY, zoomAmount } = this.imageTarget.dataset
    const { left: imageLeft, top: imageTop } = this.imageTarget.getBoundingClientRect()

    const x = Math.round((clientX - imageLeft) / parseFloat(zoomAmount) - (((parseFloat(viewportX) / 2)) / parseFloat(zoomAmount)) + parseFloat(mapX))
    const y = Math.round((clientY - imageTop) / parseFloat(zoomAmount) - (((parseFloat(viewportY) / 2)) / parseFloat(zoomAmount)) + parseFloat(mapY))
    return { x, y }
  }

  cableReceived(data) {
    switch (data.operation) {
      case "revealArea": {
        if (!this.getFogArea(data.id)) {
          this.createFogArea(data.id, JSON.parse(data.path))
        }
      }
    }
  }

  createFogArea(id, path) {
    const areas = this.fogAreas
    this.fogAreas = [...areas, { id: id, path: path, addedAt: Date.now() }]
    this.drawCanvas()
  }

  addFogArea(id, x, y) {
    const areas = this.fogAreas
    this.fogAreas = [...areas, { id: id, path: [{ x, y }] }]
    this.drawCanvas()
  }

  updateFogArea(id, x, y) {
    const areas = this.fogAreas
    this.fogAreas = areas.map(area => {
      if (area.id == id) {
        area.path = [...area.path, { x, y }]
      }
      return area
    })
    this.drawCanvas()
  }

  getFogArea(id) {
    const areas = this.fogAreas
    return areas.find(area => area.id == id)
  }

  startDrawingFog(event) {
    if(event.shiftKey) {
      event.stopImmediatePropagation()
      const { x: startX, y: startY } = this.mapPositionOf(event)
      const id = uuid()
      this.addFogArea(id, startX, startY)

      const drawFog = event => {
        event.stopImmediatePropagation()
        const { x, y } = this.mapPositionOf(event)
        this.updateFogArea(id, x, y)
      }

      document.onmouseup = event => {
        event.stopImmediatePropagation()
        this.channel.perform(
          "reveal_area",
          {
            map_id: this.mapId,
            id: id,
            path: JSON.stringify(this.getFogArea(id).path)
          }
        )
        document.removeEventListener("mousemove", drawFog)
        document.onmouseup = null
      }
      document.addEventListener("mousemove", drawFog)
    }
  }

  get fogAreas() {
    return JSON.parse(this.canvasTarget.dataset["map-FogAreas"])
  }

  set fogAreas(areas) {
    this.canvasTarget.dataset["map-FogAreas"] = JSON.stringify(areas)
  }
}
