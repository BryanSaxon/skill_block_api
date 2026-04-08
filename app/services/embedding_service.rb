require "net/http"
require "uri"
require "json"

# Generates text embeddings via OpenAI's embedding API.
# Uses text-embedding-3-small (1536 dimensions).
class EmbeddingService
  DIMENSIONS = 1536
  MODEL = "text-embedding-3-small"
  BATCH_SIZE = 100
  ENDPOINT = URI("https://api.openai.com/v1/embeddings")

  def self.embed_batch(texts)
    return [] if texts.empty?

    api_key = Rails.application.credentials.dig(:openai, :api_key) ||
              ENV["OPENAI_API_KEY"]
    raise "OPENAI_API_KEY not configured" if api_key.blank?

    embeddings = []
    texts.each_slice(BATCH_SIZE) do |batch|
      body = {model: MODEL, input: batch}.to_json

      http = Net::HTTP.new(ENDPOINT.host, ENDPOINT.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(ENDPOINT.path)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{api_key}"
      request.body = body

      response = http.request(request)
      parsed = JSON.parse(response.body)

      raise "Embedding API error: #{parsed["error"]&.dig("message")}" unless response.is_a?(Net::HTTPSuccess)

      batch_embeddings = parsed["data"]
        .sort_by { |d| d["index"] }
        .map { |d| d["embedding"] }

      embeddings.concat(batch_embeddings)
    end

    embeddings
  end
end
