import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "suggestions"]

  async search(event) {
    const query = event.target.value

    if (query.length < 3) {
      this.suggestionsTarget.innerHTML = ""
      this.suggestionsTarget.classList.add("d-none")
      return
    }

    const response = await fetch(`/places/autocomplete?query=${query}`)
    const cities = await response.json()

    console.log(cities)
    this.renderSuggestions(cities)
  }

  // async search(event) {
  //   const query = event.target.value.trim()
  //
  //   if (query.length < 3) return
  //
  //   const response = await fetch(
  //       `https://api.maptiler.com/geocoding/${query}.json?key=YOUR_KEY&types=place,region&country=pt`
  //   )
  //
  //   const data = await response.json()
  //
  //   const cities = data.features.map(f => ({
  //     name: f.text,
  //     lat: f.center[1],
  //     lng: f.center[0]
  //   }))
  //
  //   this.renderSuggestions(cities)
  // }

  renderSuggestions(cities) {
    this.suggestionsTarget.classList.remove("d-none")
    this.suggestionsTarget.innerHTML = ""

    const list = document.createElement("ul")
    list.classList.add("list-group")
    this.suggestionsTarget.appendChild(list)

    if(cities.length === 0) {
      this.suggestionsTarget.innerHTML = "Not found"
      return
    }

    cities.forEach(city => {
      const item = document.createElement("item")
      item.classList.add("list-group-item")
      item.textContent = city.name

      item.addEventListener("click", () => {
        this.selectCity(city)
      })

      list.appendChild(item)
    })

  }

  selectCity(city) {
    window.dispatchEvent(
        new CustomEvent("city:selected", {
          detail: city
        })
    )
    this.centerOnPlace(city)
    this.suggestionsTarget.classList.add("d-none")
  }
}