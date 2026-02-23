
export function loadLocation() {
    return new Promise((resolve) => {
        const DEFAULT_LOCATION = { lat: 38.7223, long: -9.1393 }
        const lat = localStorage.getItem("lat")
        const long = localStorage.getItem("long")

        if(lat && long ) {
            resolve({ lat: parseFloat(lat) , long: parseFloat(long) })
        }

        navigator.geolocation.getCurrentPosition(
            (position) => {
                localStorage.setItem("lat", position.coords.latitude.toString())
                localStorage.setItem("long", position.coords.longitude.toString())
                resolve({ lat: position.coords.latitude, long: position.coords.longitude })
            },
            () => {
                resolve({ lat: DEFAULT_LOCATION.lat , long: DEFAULT_LOCATION.long })
            }
        )

    })
}