import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions", "wrapper"]

  async search(event) {
    const query = event.target.value

    if (query.length < 2) {
      this.suggestionsTarget.innerHTML = ""
      this.suggestionsTarget.classList.add("d-none")
      return
    }

    const [placesRes, markersRes] = await Promise.all([
      fetch(`/places/autocomplete?query=${encodeURIComponent(query)}`),
      fetch(`/markers/search?query=${encodeURIComponent(query)}`)
    ])

    const places = await placesRes.json()
    const markers = await markersRes.json()

    this.renderResults(places, markers)
  }

  renderResults(places, markers) {
    this.suggestionsTarget.classList.remove("d-none")
    this.suggestionsTarget.innerHTML = ""

    if (places.length === 0 && markers.length === 0) {
      this.suggestionsTarget.innerHTML = '<span class="text-muted small p-2">No results</span>'
      return
    }

    if (markers.length > 0) {
      const header = document.createElement("div")
      header.className = "text-muted small fw-semibold px-2 pt-1 pb-1"
      header.textContent = "Markers"
      this.suggestionsTarget.appendChild(header)

      markers.forEach(marker => {
        const icons = marker.categories.map(c =>
          `<i class="map-marker-icon ${c.icon || 'fa-solid fa-location-dot'}" style="--marker-color:${c.color || '#6c757d'};font-size:0.85rem;"></i>`
        ).join(" ")

        const item = document.createElement("div")
        item.className = "search-result d-flex align-items-center gap-2 px-2 py-1"
        item.innerHTML = `
          <span>${icons}</span>
          <div class="flex-grow-1 overflow-hidden">
            <div class="text-truncate small fw-semibold">${marker.name}</div>
            ${marker.address ? `<div class="text-muted text-truncate" style="font-size:0.75rem;">${marker.address}</div>` : ''}
          </div>
        `
        item.addEventListener("click", () => this.selectMarker(marker))
        this.suggestionsTarget.appendChild(item)
      })
    }

    if (places.length > 0) {
      const header = document.createElement("div")
      header.className = "text-muted small fw-semibold px-2 pt-2 pb-1"
      header.textContent = "Locations"
      this.suggestionsTarget.appendChild(header)

      places.forEach(place => {
        const item = document.createElement("div")
        item.className = "search-result d-flex align-items-center gap-2 px-2 py-1"
        item.innerHTML = `
          <i class="bi bi-geo-alt text-muted"></i>
          <span class="small text-truncate">${place.name}</span>
        `
        item.addEventListener("click", () => this.selectCity(place))
        this.suggestionsTarget.appendChild(item)
      })
    }
  }

  toggle() {
    if (this.hasWrapperTarget) {
      this.wrapperTarget.classList.toggle("d-none")
      this.wrapperTarget.classList.toggle("d-flex")
      if (!this.wrapperTarget.classList.contains("d-none")) {
        this.inputTarget.focus()
      }
    }
  }

  selectCity(city) {
    window.dispatchEvent(new CustomEvent("city:selected", { detail: city }))
    this.close()
  }

  selectMarker(marker) {
    window.dispatchEvent(new CustomEvent("marker:selected", { detail: marker }))
    this.close()
  }

  close() {
    this.suggestionsTarget.classList.add("d-none")
    this.inputTarget.value = ""
  }
}
