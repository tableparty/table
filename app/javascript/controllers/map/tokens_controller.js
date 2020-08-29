import { Controller } from "stimulus"
import consumer from "../../channels/consumer"

export default class extends Controller {
  static targets = ["container", "drawer", "token", "image", "tokenActions"]

  connect() {
    this.mapId = this.element.dataset.mapId
    this.selectedTokens = []

    this.tokenTargets.forEach(target => {
      target.ondragstart = () => null
    })

    this.channel = consumer.subscriptions.create({
      channel: "Maps::TokensChannel",
      id: this.mapId
    }, {
      received: this.cableReceived.bind(this)
    })
  }

  cableReceived(data) {
    switch (data.operation) {
      case "addToken": {
        if (this.findToken(data.token_id)) {
          return
        }
        this.containerTarget.insertAdjacentHTML("beforeend", data.token_html);
        const token = this.findToken(data.token_id)
        if (data.stashed) {
          if (this.hasDrawerTarget) {
            this.drawerTarget.appendChild(token)
          } else {
            token.remove()
          }
        }
        break;
      }
      case "stashToken": {
        const token = this.findToken(data.token_id)
        if (this.hasDrawerTarget) {
          this.drawerTarget.appendChild(token)
        } else {
          token.remove()
        }
        break
      }
      case "deleteToken": {
        const token = this.findToken(data.token_id)
        token.remove()
        break
      }
    }
  }

  startMoveToken(event) {
    event.stopPropagation()
    if (this.hasDrawerTarget) {
      this.drawerTarget.dispatchEvent(new CustomEvent('open'))
    }

    const { target, clientX, clientY } = event
    this.recordPointerLocation(event.clientX, event.clientY)
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
    const { x: currentX, y: currentY, offsetX, offsetY } = target.dataset
    const { zoomAmount } = this.imageTarget.dataset
    const { x, y } = this.mapPositionOf(
      new MouseEvent("drag", {
        clientX: this.element.dataset.clientX,
        clientY: this.element.dataset.clientY
      })
    )

    const newX = Math.floor(x + (parseFloat(offsetX) / parseFloat(zoomAmount)))
    const newY = Math.floor(y + (parseFloat(offsetY) / parseFloat(zoomAmount)))

    if (newX != currentX || newY != currentY) {
      this.setTokenLocation(
        target,
        newX,
        newY
      )
    }
  }

  endMoveToken({ target }) {
    delete target.dataset.beingDragged
    delete target.dataset.offsetX
    delete target.dataset.offsetY
  }

  setTokenLocation(token, x, y) {
    token.dataset.x = x
    token.dataset.y = y
  }

  recordPointerLocation(clientX, clientY) {
    this.element.dataset.clientX = clientX
    this.element.dataset.clientY = clientY
  }

  dragOver(event) {
    this.recordPointerLocation(event.clientX, event.clientY)
  }

  dragOverDrawer(event) {
    event.stopPropagation()
    event.preventDefault()
    var dragging = this.tokenTargets.find(token => token.dataset.beingDragged)
    if (dragging && dragging.parentNode != this.drawerTarget) {
      this.drawerTarget.appendChild(dragging)
    }
  }

  dragOverToken(event) {
    event.stopPropagation()
    var draggedOver = event.target
    var dragging = this.tokenTargets.find(token => token.dataset.beingDragged)
    if (this.hasDrawerTarget && draggedOver.parentNode == this.drawerTarget && dragging) {
      this.drawerTarget.insertBefore(dragging, draggedOver)
    }
  }

  dropOnDrawer(event) {
    event.preventDefault()
    const tokenId = event.dataTransfer.getData("text/plain")

    const token = this.findToken(tokenId)
    if (token.parentNode != this.drawerTarget) {
      this.drawerTarget.appendChild(token)
    }
    this.drawerTarget.dispatchEvent(new CustomEvent('close'))

    this.channel.perform(
      "stash_token",
      {
        map_id: this.mapId,
        token_id: tokenId
      }
    )
    this.endMoveToken({ target: token })
  }

  dragOverMap(event) {
    event.preventDefault()
  }

  dropOnMap(event) {
    event.preventDefault()
    const tokenId = event.dataTransfer.getData("text/plain")

    const token = this.findToken(tokenId)
    if (this.hasDrawerTarget) {
      this.drawerTarget.dispatchEvent(new CustomEvent('close'))
    }
    if (token.parentNode != this.containerTarget) {
      if (token.dataset.copyOnPlace != "true") {
        this.containerTarget.appendChild(token)
      }

      this.channel.perform(
        "place_token",
        {
          map_id: this.mapId,
          token_id: tokenId
        }
      )
    }
    this.endMoveToken({ target: token })
  }

  findToken(tokenId) {
    return this.tokenTargets.find(token => token.dataset.tokenId == tokenId)
  }

  mapPositionOf(event) {
    const { clientX, clientY } = event
    const { viewportX, viewportY, x: mapX, y: mapY, zoomAmount } = this.imageTarget.dataset
    const { left: imageLeft, top: imageTop } = this.imageTarget.getBoundingClientRect()

    const x = Math.round((clientX - imageLeft) / parseFloat(zoomAmount) - (((parseFloat(viewportX) / 2)) / parseFloat(zoomAmount)) + parseFloat(mapX))
    const y = Math.round((clientY - imageTop) / parseFloat(zoomAmount) - (((parseFloat(viewportY) / 2)) / parseFloat(zoomAmount)) + parseFloat(mapY))
    return { x, y }
  }

  toggleTokenSelect(event) {
    const clickedToken = event.target

    if (this.selectedTokens.includes(clickedToken)) {
      this.selectedTokens = this.selectedTokens.filter(item => {
        item !== clickedToken
      })
    } else {
      this.selectedTokens = [clickedToken]
    }

    this.tokenTargets.forEach(target => {
      target.classList.toggle("selected", this.selectedTokens.includes(target))
    })
    if (this.hasTokenActionsTarget) {
      this.tokenActionsTarget.classList.toggle(
        "enabled",
        this.selectedTokens.length > 0
      )
    }
  }

  delete(event) {
    if (confirm(`Are you sure you want to delete the selected tokens?`)) {
      this.selectedTokens.forEach(token => {
        this.channel.perform(
          "delete_token",
          {
            map_id: this.mapId,
            token_id: token.dataset.tokenId
          }
        )
      })

      // TODO: unselect tokens
    }
  }

  stash(event) {
    this.selectedTokens.forEach(token => {
      this.channel.perform(
        "stash_token",
        {
          map_id: this.mapId,
          token_id: token.dataset.tokenId
        }
      )
    })

    // TODO: unselect tokens
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
