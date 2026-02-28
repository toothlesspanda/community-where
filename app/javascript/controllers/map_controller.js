import { Controller } from "@hotwired/stimulus"
import L from 'leaflet'
import { loadLocation } from "../location"

export default class extends Controller {
  static targets = ["map", "field", "form"]
  static values = { url: String }

  async connect() {
    const location = await loadLocation()

    const lat = location?.lat
    const long = location?.long

    this.map = L.map(this.mapTarget).setView([lat, long], 13)

    L.tileLayer('https://api.maptiler.com/maps/dataviz/{z}/{x}/{y}.png?key=F9todpBjCHkc7mTUrK6i', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap'
    }).addTo(this.map)

    this.markersLayer = L.layerGroup().addTo(this.map)

    await this.loadMarkers()

    this.map.on("moveend", () => {
      this.loadMarkers()
    })

    window.addEventListener("city:selected", this.handleCitySelected)
  }

  filtersChanged() {
    this.debouncedLoad()
  }

  debouncedLoad() {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(async () => {
      await this.loadMarkers()
    }, 250)
  }

  async loadMarkers() {
    const params = new URLSearchParams(new FormData(this.formTarget))

    const bounds = this.map.getBounds()

    params.append("bbox", [
      bounds.getWest(),
      bounds.getSouth(),
      bounds.getEast(),
      bounds.getNorth()
    ].join(","))

    const response = await fetch(`${this.urlValue}?${params}`,{ headers: { "Accept": "application/json" }})
    const data = await response.json()
    this.markersLayer.clearLayers()
    this.addMarkers(data)
  }

  addMarkers(data){
    data.forEach(marker  => {
      this.addMarker(marker)
    })
  }

  addMarker(marker) {
    let categories = ""

    marker.categories.forEach((cat, index) => {
      categories+= `<span class="badge text-bg-primary ${index !== 0 ? "ms-2" : ""}"> ${cat.parent}: ${cat.code}</span>`
    })

    L.marker(
        [marker.latitude, marker.longitude],
        { icon: this.coloredIcon(marker.categories[0].color) })
        .addTo(this.markersLayer)
        .bindPopup(`
          <div>
             <span class="fs-5">${marker.name}</span>
              <p class="my-1 text-muted">${marker.description}</p>
              <div class="my-3">
                  ${categories}
              </div>
          </div>
 
        `)
  }

  coloredIcon(color) {
    console.log(color)
    return L.divIcon({
      className: "",
      html: `
      <div style="
        background:${color};
        width:16px;
        height:16px;
        border-radius:50%;
        border:2px solid white;
        box-shadow:0 0 4px rgba(0,0,0,0.3);
      "></div>
    `,
      iconSize: [16, 16],
      iconAnchor: [8, 8]
    })
  }

  handleCitySelected = (event) => {
    const { lat, lng, depth } = event.detail
    let zoom

    if (depth === 3) {
      zoom = 14
    } else if (depth === 2) {
      zoom = 12
    } else {
      zoom = 9
    }

    this.map.setView([lat, lng], zoom)
  }
}
