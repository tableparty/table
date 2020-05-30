import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["container"]

  close(event) {
    event.preventDefault()
    this.removeModal()
  }

  removeModal() {
    this.element.parentNode.removeChild(this.element)
  }

  onPostError(event) {
    event.target.outerHTML = event.detail[2].response;
  }

  onDeleteError(event) {
    event.stopPropagation()
    alert("There was an problem when attempting to delete.")
  }
}
