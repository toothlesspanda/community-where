import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    submitEnd(event) {
        if (event.detail.success) {
            this.element.reset()

            // Switch back to main sidebar view
            document.getElementById("sidebar-form")?.classList.add("d-none")
            document.getElementById("sidebar-main")?.classList.remove("d-none")
            document.getElementById("new-marker-message")?.classList.add("d-none")

            // Remove selection marker from map
            const mapEl = document.querySelector("[data-controller='map']")
            const mapController = this.application.getControllerForElementAndIdentifier(mapEl, "map")
            mapController?.removeSelectionMarker()
        }
    }
}
