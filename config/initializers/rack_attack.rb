class Rack::Attack
  throttle("markers/create", limit: 5, period: 1.minute) do |req|
    if req.path == "/marker_submissions" && req.post?
      req.ip
    end
  end
end

Rack::Attack.throttled_responder = lambda do |env|
  [ 429, { "Content-Type" => "text/plain" }, ["Demasiados pedidos. Tenta novamente mais tarde."] ]
end
