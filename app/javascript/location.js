
export function loadLocation({ force = false } = {}) {
    return new Promise((resolve) => {
        const DEFAULT_LOCATION = { lat: 38.7223, long: -9.1393 }

        if (!force) {
            const lat = sessionStorage.getItem("lat")
            const long = sessionStorage.getItem("long")
            const name = sessionStorage.getItem("name")

            if (lat && long) {
                return resolve({ lat: parseFloat(lat), long: parseFloat(long), name: name })
            }
        }

        if (!navigator.geolocation) {
            return resolve({ lat: DEFAULT_LOCATION.lat, long: DEFAULT_LOCATION.long, name: null })
        }

        navigator.geolocation.getCurrentPosition(
            async (position) => {
                const pos_lat = position.coords.latitude.toString()
                const pos_long = position.coords.longitude.toString()
                sessionStorage.setItem("lat", pos_lat)
                sessionStorage.setItem("long", pos_long)

                const pos_name = await getPositionName(pos_lat, pos_long)
                sessionStorage.setItem("name", pos_name.toString())
                resolve({ lat: position.coords.latitude, long: position.coords.longitude, name: pos_name })
            },
            () => {
                resolve({ lat: DEFAULT_LOCATION.lat, long: DEFAULT_LOCATION.long, name: null })
            },
            { enableHighAccuracy: true, timeout: 10000 }
        )
    })
}

async function getPositionName(pos_lat, pos_long) {
    const response = await fetch(`/places?lat=${pos_lat}&long=${pos_long}`)
    const place = await response.json()
    return place.name
}
