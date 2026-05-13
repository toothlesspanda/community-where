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
    this.location_coordinates = await this.setupLocation()

    this.setupMap(this.location_coordinates);

    await this.loadMarkers()

    this.map.on("moveend", this.loadMarkers.bind(this))
    this.map.on("click", this.handleMapClick.bind(this))

    window.addEventListener("city:selected", this.handleCitySelected)
    this.modal = new bootstrap.Modal(document.getElementById("newMarkerModal"))
    window.addEventListener("hidden.bs.modal", this.disableAddMode.bind(this))
  }

  disconnect() {
    window.removeEventListener("city:selected", this.handleCitySelected)
    window.removeEventListener("hidden.bs.modal", this.disableAddMode.bind(this))
  }


  resetMapPosition(){
    this.map.setView(this.location_coordinates)
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
    document.getElementById("map").style.boxShadow = "inset 1px 0px 0px 17px rgba(220, 53, 69)"
    document.getElementById("map").style.padding = "10px"
    this.map.getContainer().style.cursor = "crosshair"
    document.getElementById("new-marker-message").classList.remove("d-none")
  }

  disableAddMode() {
    this.addMode = false
    this.map.getContainer().style.cursor = ""
    document.getElementById("map").style.padding = ""
    document.getElementById("map").style.boxShadow = ""
    document.getElementById("new-marker-message").classList.add("d-none")
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
    const catGroupedby = Object.groupBy(marker.categories, cat => cat.parent);

    console.log(catGroupedby)
    for(let [parentKey,cats] of Object.entries(catGroupedby)){
      categories+= `<div> <span class="me-2">${parentKey}:</span>`

      for(let category of cats){
        categories+= `<span class="badge border border-2 border-primary text-primary">${category.code}</span>`
      }
      categories+= `</div>`
    }

    const googleLink = `https://www.google.com/maps/search/?api=1&query=${marker.latitude},${marker.longitude},z15`;

    L.marker(
        [marker.latitude, marker.longitude],
        { icon: this.coloredIcon(marker.categories[0].color) }
          )
        .addTo(this.markersLayer)
        .bindPopup(`
          <div class="popup-content">
             <span class="fs-5">${marker.name}</span><br>
              <p class="my-1 text-muted">${marker.description}</p>
              <span class="fs-10">
                <button class="btn btn-link btn-mute p-0 fs-10 fs-12" data-action="click->map#copyToClipboard" 
                  data-link="${googleLink}">
                    Google Maps link <i class="bi bi-copy"></i>
                </button>
              </span>
              <div class="divider my-1"></div>
              <div class="my-3">
                  ${categories}
              </div>
          </div>
        `, {
          className: "custom-popup"
        }).on("popupopen", (e) => {
          const popupEl = e.popup.getElement()
          popupEl.style.setProperty("--popup-color", marker.categories[0].color)
        }
      )
  }

  copyToClipboard(event){
    event.preventDefault();
    const link = event.currentTarget.dataset.link;

    navigator.clipboard.writeText(link).then(() => {
      let tooltip = new bootstrap.Tooltip(event.currentTarget, {
        title: "Copied!",
        trigger: "manual"
      });

      tooltip.show();
      setTimeout(() => tooltip.dispose(), 1500);
    });
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
    if(this.addMode == false) return;
    const { lat, lng } = e.latlng

    document.getElementById("latField").value = lat
    document.getElementById("lngField").value = lng
    
    document.getElementById("latHidden").value = lat
    document.getElementById("lngHidden").value = lng

    this.modal.show()

    this.addMode = false
    this.map.getContainer().style.cursor = ""
  }
}
