import { Controller } from "stimulus"
import consumer from "../../channels/consumer"
import Rails from "@rails/ujs"

export default class extends Controller {
  static targets = ["container", "drawer", "token", "image", "actions", "action"]

  connect() {
    this.mapId = this.element.dataset.mapId

    this.tokenTargets.forEach(target => {
      target.ondragstart = () => null
    })

    this.channel = consumer.subscriptions.create({
      channel: "Maps::TokensChannel",
      id: this.mapId
    }, {
      received: this.cableReceived.bind(this)
    })

    document.addEventListener("keyup", this.handleKeys.bind(this))
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
      case "updateToken": {
        const token = this.findToken(data.token_id)
        if (token) {
          token.outerHTML = data.token_html
          if (data.stashed) {
            if (this.hasDrawerTarget) {
              this.drawerTarget.appendChild(token)
            } else {
              token.remove()
            }
          }
        }
        break;
      }
    }
  }

  moveStarted(event) {
    event.stopPropagation()
    if (this.hasDrawerTarget) {
      this.drawerTarget.dispatchEvent(new CustomEvent('open'))
    }

    const { target, clientX, clientY } = event
    this.recordPointerLocation(event.clientX, event.clientY)

    this.startMoveToken(target, clientX, clientY)
    this.selectedTokens().forEach(selectedToken => this.startMoveToken(selectedToken, clientX, clientY))

    event.dataTransfer.setData("text/plain", target.dataset.tokenId)
  }

  startMoveToken(token, clientX, clientY) {
    const { left, top } = token.getBoundingClientRect()

    const tokenImage = token.getElementsByClassName("token__image")[0]
    const { width: tokenWidth, height: tokenHeight } = tokenImage.getBoundingClientRect()

    token.dataset.beingDragged = true
    token.dataset.offsetX = (tokenWidth / 2) - (clientX - left)
    token.dataset.offsetY = (tokenHeight / 2) - (clientY - top)
  }

  moved(event) {
    event.stopPropagation()
    const { target } = event

    this.moveToken(target)
    this.performOnSelected(this.moveToken.bind(this), false)
  }

  moveToken(token) {
    const { x: currentX, y: currentY, offsetX, offsetY } = token.dataset
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
        token,
        newX,
        newY
      )
    }
  }

  moveEnded({ target }) {
    this.endMoveToken(target)
    this.performOnSelected(this.endMoveToken.bind(this), false)
  }

  endMoveToken(token) {
    delete token.dataset.beingDragged
    delete token.dataset.offsetX
    delete token.dataset.offsetY
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
    const token = this.findToken(event.dataTransfer.getData("text/plain"))

    this.stashToken(token)
    this.performOnSelected(this.stashToken.bind(this))

    this.drawerTarget.dispatchEvent(new CustomEvent('close'))
  }

  stashToken(token) {
    if (token.parentNode != this.drawerTarget) {
      this.drawerTarget.appendChild(token)
    }
    this.channel.perform(
      "stash_token",
      {
        map_id: this.mapId,
        token_id: token.dataset.tokenId
      }
    )
  }

  dragOverMap(event) {
    event.preventDefault()
  }

  dropOnMap(event) {
    event.preventDefault()
    if (this.hasDrawerTarget) {
      this.drawerTarget.dispatchEvent(new CustomEvent('close'))
    }
    const token = this.findToken(event.dataTransfer.getData("text/plain"))

    this.placeToken(token)
    this.performOnSelected(this.placeToken.bind(this))
  }

  placeToken(token) {
    if (token.parentNode != this.containerTarget) {
      if (token.dataset.copyOnPlace != "true") {
        this.containerTarget.appendChild(token)
      }
      this.channel.perform(
        "place_token",
        {
          map_id: this.mapId,
          token_id: token.dataset.tokenId
        }
      )
    }
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

    if (clickedToken.dataset.selected) {
      this.unselectToken(clickedToken)
    } else {
      this.selectToken(clickedToken)
    }

    if (!event.shiftKey && !event.metaKey) {
      this.tokenTargets.forEach(token => {
        if (token != clickedToken) {
          this.unselectToken(token)
        }
      })
    }
  }

  handleKeys(event) {
    if (event.target != document.body) {
      return
    }

    if (event.code == "ArrowRight" || event.code == "ArrowLeft") {
      this.selectWithKeyboard(event)
    } else if (event.key == "t") {
      this.drawerTarget.dispatchEvent(new CustomEvent("toggle"))
    } else if (this.hasTokenSelected()) {
      switch (event.key) {
        case "Backspace":
        case "Delete":
          this.deleteSelected()
          break
        case "s":
          this.stashSelected()
          break
        case "e":
          this.editSelected()
          break
      }
    }
  }

  selectWithKeyboard(event) {
    var index = 0
    const selectedTokens = this.selectedTokens()
    const availableTokens = this.tokenTargets.filter(token => {
      if (this.hasDrawerTarget && !this.drawerTarget.classList.contains("show") && token.parentNode == this.drawerTarget) {
        return false
      } else {
        return true
      }
    })
    if (availableTokens.length > 0) {
      if (selectedTokens.length > 0) {
        index = availableTokens.indexOf(selectedTokens[selectedTokens.length - 1]) + (event.code == "ArrowRight" ? 1 : -1)
      }
      if (index >= availableTokens.length) {
        index = 0
      }
      if (index < 0) {
        index = availableTokens.length - 1
      }
      this.toggleTokenSelect({
        target: availableTokens[index],
        shiftKey: event.shiftKey,
        metaKey: event.metaKey
      })
    }
  }

  selectToken(token) {
    token.dataset.selected = true
    this.toggleTokenActions()
  }

  unselectToken(token) {
    delete token.dataset.selected
    this.toggleTokenActions()
  }

  hasTokenSelected() {
    return this.tokenTargets.some(token => { return token.dataset.selected })
  }

  selectedTokens() {
    return this.tokenTargets.filter(token => token.dataset.selected)
  }

  toggleTokenActions() {
    if (this.hasActionsTarget) {
      this.actionTargets.forEach(action => action.disabled = !this.hasTokenSelected())
    }
  }

  deleteSelected() {
    if (this.hasTokenSelected() && confirm(`Are you sure you want to delete the selected tokens?`)) {
      this.performOnSelected(token => {
        this.channel.perform(
          "delete_token",
          { map_id: this.mapId, token_id: token.dataset.tokenId }
        )
      })
    }
  }

  performOnSelected(operation, unselectAfterOperation = true) {
    this.selectedTokens().forEach(token => {
      operation(token)
      if (unselectAfterOperation) {
        this.unselectToken(token)
      }
    })
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
    if (this.hasActionsTarget) {
      this.actionsTarget.classList.toggle(
        "enabled",
        this.hasTokenSelected()
      )
      this.actionTargets.forEach(action => {
        action.disabled = !this.hasTokenSelected()
      })
    }
  }

  stashSelected() {
    this.performOnSelected(this.stashToken.bind(this))
  }

  editSelected() {
    this.performOnSelected(token => {
      Rails.ajax({
        type: 'GET',
        url: token.dataset.editUrl,
        dataType: "script"
      })
    })
  }

  stopPropagation(event) {
    event.stopPropagation()
  }
}
