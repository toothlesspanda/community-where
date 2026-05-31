class LlmClient
  API_URL = "https://api.groq.com/openai/v1/chat/completions"

  class ApiLimitError < StandardError; end

  def initialize(
    api_key: ENV.fetch("GROQ_API_KEY"),
    model: ENV.fetch("LLM_MODEL", "llama-3.3-70b-versatile")
  )
    @api_key = api_key
    @model = model
  end

  def chat(messages, max_tokens: 1024)
    body = {
      model: @model,
      max_tokens: max_tokens,
      messages: messages,
      response_format: { type: "json_object" }
    }

    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{@api_key}"
    request.body = body.to_json

    response = http.request(request)

    if response.code == "429"
      raise ApiLimitError, "Rate limit reached. Retry after: #{response['retry-after']}s"
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "LLM API error #{response.code}: #{response.body}"
    end

    parsed = JSON.parse(response.body)
    parsed.dig("choices", 0, "message", "content")
  end
end
