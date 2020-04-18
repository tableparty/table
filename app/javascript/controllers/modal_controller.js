import { Controller } from "stimulus"

export default class extends Controller {
  close(event) {
    event.preventDefault()
    this.element.parentNode.removeChild(this.element)
  }
}
