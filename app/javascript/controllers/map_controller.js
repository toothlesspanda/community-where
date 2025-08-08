
import { Controller } from "@hotwired/stimulus"
import L from 'leaflet'

// Estilo do ícone padrão (Leaflet precisa disto manualmente via JS)
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: null,
  iconUrl: null,
  shadowUrl: null,
});

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
    const [latitude, longitude] = place;
    L.marker([latitude, longitude])
        .addTo(this.map)
        .bindPopup(`<div>latitude: ${latitude}</div><div>longitude: ${longitude}</div>`)
  }
}
