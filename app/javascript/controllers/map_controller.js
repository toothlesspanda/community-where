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

    this.latlongValue.forEach(place => this.addMarker(place))
  }

  addMarker(place) {
    L.marker([place.latitude, place.longitude])
        .addTo(this.map)
        .bindPopup(`<div>Title: ${place.name}</div><div>Description: ${place.description}</div>`)
  }
}
