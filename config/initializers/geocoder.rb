Geocoder.configure(
  lookup: :nominatim,
  http_headers: {
    "User-Agent" => "your_app_name"
  },
  timeout: 5
)