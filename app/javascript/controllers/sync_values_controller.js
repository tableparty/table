import { Controller } from "stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  connect() {
    this.syncedVariables = this.data.get("keys").split(" ")
    this.operatorCode = this.generateOperatorCode()

    this.initializeObserver()
    this.initializeChannel()

    this.connectObserver()
  }

  disconnect() {
    this.observer.disconnect()
  }

  cableReceived(data) {
    if(data["operator"] == this.operatorCode) {
      return
    }

    this.disconnectObserver()

    this.syncedVariables.forEach(variable => {
      if (data[variable] == undefined) {
        return
      }

      this.element.dataset[variable] = data[variable]
    })

    this.connectObserver()
  }

  initializeChannel() {
    this.channel = consumer.subscriptions.create({
      channel: this.data.get("channel"),
      id: this.data.get("channelId")
    }, {
      received: this.cableReceived.bind(this)
    })
  }

  initializeObserver() {
    this.observerOptions = {
      attributes: true,
      attributeFilter: this.syncedVariables.map(this.variableNameToDataAttribute)
    }

    this.observer = new MutationObserver(mutations => {
      const attributes = mutations.reduce((changedAttributes, mutation) => {
        const varName = this.dataAttributeToVariableName(mutation.attributeName)
        changedAttributes[varName] = mutation.target.dataset[varName]
        return changedAttributes
      }, {
        operator: this.operatorCode,
        id: this.data.get("channelId")
      })
      this.channel.perform(this.data.get("action"), attributes)
    })
  }

  connectObserver() {
    this.observer.observe(this.element, this.observerOptions)
  }

  disconnectObserver() {
    this.observer.disconnect()
  }

  variableNameToDataAttribute(variableName) {
    return `data-${variableName}`
  }

  dataAttributeToVariableName(dataName) {
    return dataName.match(/data-(.+)/)[1]
  }

  generateOperatorCode() {
    return Array
      .from(window.crypto.getRandomValues(new Uint8Array(32)))
      .map(c => (c < 16 ? "0" : "") + c.toString(16)).join([]);
  }
}
