import { Controller } from "@hotwired/stimulus"
import L from 'leaflet'
import "leaflet.markercluster"

import { loadLocation } from "../location"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static targets = ["map", "field", "form"]
  static values = { url: String }

  async connect() {
    this.addMode = false
    const coordinates = await this.setupLocation()

    this.setupMap(coordinates);

    await this.loadMarkers()

    this.map.on("moveend", this.loadMarkers.bind(this))
    this.map.on("click", this.handleMapClick.bind(this))

    window.addEventListener("city:selected", this.handleCitySelected)
    this.modal = new bootstrap.Modal(document.getElementById("newMarker"))
  }


  async setupLocation(){
    const location = await loadLocation()

    const lat = location?.lat
    const long = location?.long
    const currentLocationElem = document.getElementById("current-location")

    if(location.name == null){
      currentLocationElem.parentElement.parentElement.classList.add("d-none")
    } else {
      currentLocationElem.parentElement.parentElement.classList.remove("d-none")
      currentLocationElem.innerText = location.name
    }

    return [lat, long]
  }

  setupMap(coordinates){
    this.map = L.map(this.mapTarget, {zoomControl: false}).setView(coordinates, 13)

    L.control.zoom({
      position: "bottomright"
    }).addTo(this.map)

    L.tileLayer('https://api.maptiler.com/maps/dataviz/{z}/{x}/{y}.png?key=F9todpBjCHkc7mTUrK6i', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap',
    }).addTo(this.map)


    this.markersLayer = L.markerClusterGroup({
      showCoverageOnHover: false,
      maxClusterRadius: 50,
      iconCreateFunction: function(cluster) {
        return L.divIcon({
          html: `<div class="map-dot-cluster">${cluster.getChildCount()}</div>`,
          className: "",
          iconSize: [40, 40]
        })
      }
    })

    this.map.addLayer(this.markersLayer)
  }

  enableAddMode() {
    this.addMode = true

    // feedback visual
    this.map.getContainer().style.cursor = "crosshair"
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
    return L.divIcon({
      className: "",
      html: `
        <div class="map-dot" style="background:${color};"></div>
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

  handleMapClick(e) {
    if (!this.addMode) return
    const { lat, lng } = e.latlng

    document.getElementById("latField").value = lat
    document.getElementById("lngField").value = lng

    document.getElementById("latHidden").value = lat
    document.getElementById("lngHidden").value = lng

    this.modal.show()

    // sair do modo automaticamente
    this.addMode = false
    this.map.getContainer().style.cursor = ""
  }
}
