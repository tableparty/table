import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.observer = new MutationObserver(mutations => {
      mutations.forEach(({ target, attributeName }) => {
        target.dataset.cssVars.split(" ").forEach(cssVar => {
          if (attributeName == `data-${cssVar}`) {
            target.style.setProperty(`--${cssVar}`, target.dataset[cssVar])
          }
        })
      })
    })

    this.setCssVars()
    this.observer.observe(this.element, { attributes: true })
  }

  disconnect() {
    this.observer.disconnect()
  }

  setCssVars() {
    this.element.dataset.cssVars.split(" ").forEach(cssVar => {
      this.element.style.setProperty(`--${cssVar}`, this.element.dataset[cssVar])
    })
  }
}
