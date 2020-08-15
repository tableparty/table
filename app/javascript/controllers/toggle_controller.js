import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle(event) {
    var toggleTarget = event.currentTarget.dataset["toggle-target"]
    var toggleClass = this.data.get("class")

    this.contentTargets.forEach((t) => {
      if (t.dataset["toggle-target"] == toggleTarget) {
        t.classList.toggle(toggleClass)
      }
    })
  }
}
