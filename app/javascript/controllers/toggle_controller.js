import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle(event) {
    this.perform(event, "toggle")
  }

  open(event) {
    this.perform(event, "add")
  }

  close(event) {
    this.perform(event, "remove")
  }

  perform(event, operation) {
    var toggleTarget = event.currentTarget.dataset.toggleTarget
    var toggleClass = this.data.get("class")

    this.contentTargets.forEach((t) => {
      if (t.dataset.toggleTarget == toggleTarget) {
        t.classList[operation](toggleClass)
      }
    })
  }
}
