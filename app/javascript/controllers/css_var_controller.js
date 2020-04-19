import { Controller } from "stimulus"

export default class extends Controller {
  connect() {
    this.mirroredVariables = this.element.dataset.cssVars.split(" ")

    this.setAllCssVariables()
    this.initializeObserver()
  }

  disconnect() {
    this.observer.disconnect()
  }

  initializeObserver() {
    this.observer = new MutationObserver(mutations => {
      mutations.forEach(({ attributeName }) => {
        this.updateVariable(this.dataAttributeToVariableName(attributeName))
      })
    })

    const observerOptions = {
      attributes: true,
      attributeFilter: this.mirroredVariables.map(this.variableNameToDataAttribute)
    }
    this.observer.observe(this.element, observerOptions)
  }

  setAllCssVariables() {
    this.mirroredVariables.forEach(variable => this.updateVariable(variable))
  }

  updateVariable(variableName)  {
    this.element.style.setProperty(
      this.variableNameToCssVariable(variableName),
      this.element.dataset[this.ensureCamelCase(variableName)]
    )
  }

  ensureCamelCase(variableName) {
    return variableName.replace(/([-_][a-z])/ig, match => {
      return match.toUpperCase()
        .replace('-', '')
        .replace('_', '');
    });
  }

  variableNameToDataAttribute(variableName) {
    return `data-${variableName}`
  }

  variableNameToCssVariable(variableName) {
    return `--${variableName}`
  }

  dataAttributeToVariableName(dataName) {
    return dataName.match(/data-(.+)/)[1]
  }
}
