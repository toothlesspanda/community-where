import { Controller } from "@hotwired/stimulus"
import L from 'leaflet'

export default class extends Controller {
  static targets = ["map", "field"]
  static values = { latlong: Array }

  connect() {
    this.map = L.map(this.mapTarget).setView([this.latValue || 38.736946, this.lngValue || -9.142685], 13)

    L.tileLayer('https://api.maptiler.com/maps/dataviz/{z}/{x}/{y}.png?key=F9todpBjCHkc7mTUrK6i', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap'
    }).addTo(this.map)

    this.latlongValue.forEach(marker => this.addMarker(marker))
  }

  addMarker(marker) {
    let categories = ""
    marker.categories.forEach((cat, index) => {
      if(!cat.parent_id) return;
      categories+= `<span class="badge text-bg-primary ${index !== 0 ? "ms-2" : ""}"> ${cat.code}</span>`
    })
    L.marker([marker.marker.latitude, marker.marker.longitude])
        .addTo(this.map)
        .bindPopup(`
          <div>
             <span class="fs-5">${marker.marker.name}</span>
              <p class="my-1 text-muted">${marker.marker.description}</p>
              <div class="my-3">
                  ${categories}
              </div>
          </div>
 
        `)
  }
}
