import { Controller } from "@hotwired/stimulus"
import L from 'leaflet'
import "leaflet.markercluster"

import { loadLocation } from "../location"
import { PORTUGAL_GEOJSON } from "../portugal_geojson"
import * as bootstrap from "bootstrap"

export default class extends Controller {
  static targets = ["map", "field"]
  static values = { url: String }

  async connect() {
    this.addMode = false
    this.currentMarkers = []
    this.leafletMarkers = []

    // Desktop: sidebar open by default. Mobile: closed.
    if (window.innerWidth < 576) {
      document.getElementById("sidebar")?.classList.add("closed")
    } else {
      document.getElementById("sidebar")?.classList.remove("closed")
    }

    this.location_coordinates = await this.setupLocation()

    this.setupMap(this.location_coordinates);

    await this.loadMarkers()

    this.map.on("moveend", this.loadMarkers.bind(this))
    this.map.on("click", this.handleMapClick.bind(this))

    window.addEventListener("city:selected", this.handleCitySelected)
    this.modal = new bootstrap.Modal(document.getElementById("newMarkerModal"))
    window.addEventListener("hidden.bs.modal", this.disableAddMode.bind(this))

    // Listen for filter changes (form is outside controller scope, in modal)
    document.getElementById("map-filter")?.addEventListener("change", () => this.filtersChanged())
  }

  disconnect() {
    window.removeEventListener("city:selected", this.handleCitySelected)
    window.removeEventListener("hidden.bs.modal", this.disableAddMode.bind(this))
  }


  async setupLocation(){
    const location = await loadLocation()

    const lat = location?.lat
    const long = location?.long

    this.locationName = location?.name || null

    return [lat, long]
  }

  setupMap(coordinates){
    const portugalBounds = [[32.0, -32.0], [42.5, -6.0]]

    this.map = L.map(this.mapTarget, {
      zoomControl: false,
      maxBounds: portugalBounds,
      maxBoundsViscosity: 0.8,
      minZoom: 5
    }).setView(coordinates, 13)

    L.control.zoom({
      position: "bottomright"
    }).addTo(this.map)

    // Recenter button
    const defaultCenter = [39.5, -8.0]
    const title = this.locationName || "Portugal"
    const RecenterControl = L.Control.extend({
      options: { position: "bottomright" },
      onAdd: () => {
        const btn = L.DomUtil.create("div", "leaflet-bar leaflet-control")
        btn.innerHTML = `<a href="#" title="${title}" role="button" aria-label="${title}" style="font-size:16px;display:flex;align-items:center;justify-content:center;"><i class="bi bi-crosshair"></i></a>`
        L.DomEvent.disableClickPropagation(btn)
        btn.querySelector("a").addEventListener("click", (e) => {
          e.preventDefault()
          if (this.locationName) {
            this.map.setView(this.location_coordinates, 13)
          } else {
            this.map.setView(defaultCenter, 7)
          }
        })
        return btn
      }
    })
    new RecenterControl().addTo(this.map)

    L.tileLayer('https://api.maptiler.com/maps/dataviz/{z}/{x}/{y}.png?key=F9todpBjCHkc7mTUrK6i', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap',
    }).addTo(this.map)

    // Gray mask outside Portugal (inverted polygon with holes)
    const world = [[-90, -180], [-90, 180], [90, 180], [90, -180]]
    const holes = []

    // Convert GeoJSON [lng,lat] to Leaflet [lat,lng]
    for (const polygon of PORTUGAL_GEOJSON.coordinates) {
      for (const ring of polygon) {
        holes.push(ring.map(([lng, lat]) => [lat, lng]))
      }
    }

    L.polygon([world, ...holes], {
      color: "#085c91",
      weight: 1,
      fillColor: "#d0d0d0",
      fillOpacity: 0.5,
      interactive: false
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

  toggleSidebar() {
    const sidebar = document.getElementById("sidebar")
    const backdrop = document.getElementById("sidebar-backdrop")
    const isMobile = window.innerWidth < 576

    sidebar.classList.toggle("closed")
    const isOpen = !sidebar.classList.contains("closed")

    // Backdrop only on mobile
    if (isMobile && backdrop) {
      backdrop.classList.toggle("d-none", !isOpen)
    }

    setTimeout(() => this.map.invalidateSize(), 50)
  }

  dismissWelcome() {
    document.getElementById("welcome-banner")?.remove()
    document.cookie = "welcome_dismissed=1;max-age=31536000;path=/"
  }

  enableAddMode() {
    this.addMode = true
    document.getElementById("map").classList.add("add-mode")
    this.map.getContainer().style.cursor = "crosshair"
    document.getElementById("new-marker-message").classList.remove("d-none")

    const sidebar = document.getElementById("sidebar")
    if (!sidebar.classList.contains("closed")) {
      sidebar.classList.add("closed")
      document.getElementById("sidebar-backdrop")?.classList.add("d-none")
      setTimeout(() => this.map.invalidateSize(), 50)
    }
  }

  disableAddMode() {
    this.addMode = false
    document.getElementById("map").classList.remove("add-mode")
    this.map.getContainer().style.cursor = ""
    document.getElementById("new-marker-message").classList.add("d-none")
  }

  filtersChanged() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.loadMarkers(), 250)
    this.updateSelectedFilters()
  }

  clearFilters() {
    this.filterForm?.querySelectorAll("input[type=checkbox]:checked").forEach(cb => cb.checked = false)
    this.filtersChanged()
  }

  updateSelectedFilters() {
    const checked = this.filterForm?.querySelectorAll("input[type=checkbox]:checked") || []
    const count = checked.length

    // Update badge count on filter button
    const badge = document.getElementById("filter-count")
    if (badge) {
      badge.textContent = count
      badge.classList.toggle("d-none", count === 0)
    }

    // Update clear button visibility
    const clearBtn = document.getElementById("clear-filters")
    if (clearBtn) clearBtn.classList.toggle("d-none", count === 0)

    // Render active filter chips in sidebar
    const container = document.getElementById("active-filters")
    if (!container) return

    const chips = Array.from(checked).map(cb => {
      const label = document.querySelector(`label[for="${cb.id}"]`)
      const name = label?.textContent?.trim()
      if (!name) return ""
      return `<button type="button" class="btn btn-sm btn-primary bg-primary bg-opacity-10 text-primary border-0 rounded-pill d-flex align-items-center gap-1 py-0 px-2"
                data-action="click->map#removeFilter" data-filter-id="${cb.id}">
                ${name} <i class="bi bi-x"></i>
              </button>`
    }).filter(Boolean)

    container.innerHTML = chips.join("")
  }

  removeFilter(event) {
    const id = event.currentTarget.dataset.filterId
    const cb = document.getElementById(id)
    if (cb) {
      cb.checked = false
      this.filtersChanged()
    }
  }

  get filterForm() {
    return document.getElementById("map-filter")
  }

  async loadMarkers() {
    const form = this.filterForm
    const params = form ? new URLSearchParams(new FormData(form)) : new URLSearchParams()

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
    this.currentMarkers = data
    this.leafletMarkers = []
    this.addMarkers(data)
    this.renderList()
  }

  addMarkers(data){
    data.forEach(marker  => {
      this.addMarker(marker)
    })
  }

  addMarker(marker) {
    let categories = ""
    const catGroupedby = Object.groupBy(marker.categories, cat => cat.parent);

    for(let [parentKey,cats] of Object.entries(catGroupedby)){
      categories+= `<div> <span class="me-2">${parentKey}:</span>`

      for(let category of cats){
        categories+= `<span class="badge border border-2 border-primary text-primary">${category.code}</span>`
      }
      categories+= `</div>`
    }

    const googleLink = `https://www.google.com/maps/search/?api=1&query=${marker.latitude},${marker.longitude},z15`;

    const leafletMarker = L.marker(
        [marker.latitude, marker.longitude],
        { icon: this.coloredIcon(marker.categories[0].color) }
          )
        .addTo(this.markersLayer)
    this.leafletMarkers.push({ data: marker, leaflet: leafletMarker })

    leafletMarker
        .bindPopup(`
          <div class="popup-content">
             <span class="fs-5">${marker.name}</span><br>
              <p class="my-1 text-muted">${marker.description}</p>
              <div class="divider my-1"></div>
              <div class="my-2">
                  ${categories}
              </div>
              <div class="d-flex align-items-center gap-2">
                <a href="${googleLink}" target="_blank" rel="noopener" class="btn btn-link btn-mute btn-sm p-0">
                  <i class="bi bi-geo-alt me-1"></i>Google Maps <i class="bi bi-box-arrow-up-right ms-1"></i>
                </a>
                <button class="btn btn-link btn-mute btn-sm p-0" data-action="click->map#copyToClipboard"
                  data-link="${googleLink}">
                  <i class="bi bi-copy"></i>
                </button>
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

  renderList() {
    const container = document.getElementById("markers-list")
    const emptyMsg = document.getElementById("list-empty")
    const countBadge = document.getElementById("list-count")
    if (!container) return

    const refLat = this.location_coordinates[0]
    const refLng = this.location_coordinates[1]

    this.sortedMarkers = [...this.currentMarkers].sort((a, b) => {
      return this.distanceKm(refLat, refLng, a.latitude, a.longitude)
           - this.distanceKm(refLat, refLng, b.latitude, b.longitude)
    })

    container.innerHTML = ""
    this.listRendered = 0
    if (countBadge) countBadge.textContent = this.sortedMarkers.length

    if (this.sortedMarkers.length === 0) {
      emptyMsg?.classList.remove("d-none")
      return
    }
    emptyMsg?.classList.add("d-none")
    this.appendListItems()
  }

  appendListItems() {
    const container = document.getElementById("markers-list")
    const PAGE_SIZE = 15
    const refLat = this.location_coordinates[0]
    const refLng = this.location_coordinates[1]
    const batch = this.sortedMarkers.slice(this.listRendered, this.listRendered + PAGE_SIZE)

    // Remove existing "load more" button
    container.querySelector(".load-more-btn")?.remove()

    batch.forEach(marker => {
      const dist = this.distanceKm(refLat, refLng, marker.latitude, marker.longitude)
      const distText = dist < 1 ? `${Math.round(dist * 1000)} m` : `${dist.toFixed(1)} km`
      const color = marker.categories[0]?.color || "#6c757d"
      const category = marker.categories[0]?.code || ""

      const item = document.createElement("button")
      item.type = "button"
      item.className = "btn btn-mute text-start p-2 d-flex align-items-start gap-2 border-bottom"
      item.innerHTML = `
        <div class="map-dot mt-1" style="background:${color};min-width:16px;"></div>
        <div class="flex-grow-1 overflow-hidden">
          <div class="fw-semibold text-truncate">${marker.name}</div>
          <div class="text-muted small text-truncate">${category}</div>
        </div>
        <span class="text-muted small text-nowrap">~${distText}</span>
      `
      item.addEventListener("click", () => {
        this.map.setView([marker.latitude, marker.longitude], 16)
        const found = this.leafletMarkers.find(m => m.data.id === marker.id)
        if (found) {
          this.map.once("moveend", () => found.leaflet.openPopup())
        }
        if (window.innerWidth < 576) {
          const sidebar = document.getElementById("sidebar")
          if (sidebar && !sidebar.classList.contains("closed")) {
            sidebar.classList.add("closed")
            document.getElementById("sidebar-backdrop")?.classList.add("d-none")
          }
        }
      })
      container.appendChild(item)
    })

    this.listRendered += batch.length

    if (this.listRendered < this.sortedMarkers.length) {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "load-more-btn btn btn-sm btn-mute text-primary w-100 py-2 mt-1"
      btn.textContent = `+ ${this.sortedMarkers.length - this.listRendered}`
      btn.addEventListener("click", () => this.appendListItems())
      container.appendChild(btn)
    }
  }

  distanceKm(lat1, lon1, lat2, lon2) {
    const R = 6371
    const dLat = (lat2 - lat1) * Math.PI / 180
    const dLon = (lon2 - lon1) * Math.PI / 180
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon/2) * Math.sin(dLon/2)
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
  }

  copyToClipboard(event){
    event.preventDefault();
    const link = event.currentTarget.dataset.link;

    const btn = event.currentTarget;
    const originalHTML = btn.innerHTML;

    navigator.clipboard.writeText(link).then(() => {
      btn.innerHTML = '<i class="bi bi-check-lg text-success"></i>';
      setTimeout(() => btn.innerHTML = originalHTML, 1500);
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
    this.reverseGeocode(lat, lng)

    this.addMode = false
    this.map.getContainer().style.cursor = ""
  }

  async reverseGeocode(lat, lng) {
    const addressField = document.getElementById("addressField")
    const addressHidden = document.getElementById("addressHidden")
    if (!addressField) return

    addressField.value = "..."

    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json&accept-language=pt`,
        { headers: { "User-Agent": "CommunityWhere/1.0" } }
      )
      const data = await response.json()
      const address = data.display_name || ""
      addressField.value = address
      addressHidden.value = address
    } catch {
      addressField.value = ""
      addressHidden.value = ""
    }
  }
}
