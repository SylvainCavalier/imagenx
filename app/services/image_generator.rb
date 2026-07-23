require 'net/http'
require 'json'
require 'openssl'

class ImageGenerator
  REPLICATE_API_URL = "https://api.replicate.com/v1/models/black-forest-labs/flux-1.1-pro/predictions"
  MAX_RETRIES = 5

  class GenerationError < StandardError; end
  class RateLimitError < GenerationError; end

  def initialize
    @api_token = ENV.fetch('REPLICATE_API_KEY')
  end

  def generate(prompt:, aspect_ratio: '1:1')
    response = create_prediction_with_retry(prompt, aspect_ratio)
    poll_for_result(response)
  end

  private

  def http_client(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    cert_store = OpenSSL::X509::Store.new
    cert_store.set_default_paths
    http.cert_store = cert_store
    http.open_timeout = 10
    http.read_timeout = 30
    http
  end

  def create_prediction_with_retry(prompt, aspect_ratio)
    retries = 0
    loop do
      uri = URI(REPLICATE_API_URL)
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Token #{@api_token}"
      request['Content-Type'] = 'application/json'
      request.body = {
        input: {
          prompt: prompt,
          aspect_ratio: aspect_ratio,
          output_format: 'png'
        }
      }.to_json

      response = http_client(uri).request(request)

      if response.code == '429'
        retries += 1
        raise RateLimitError, "Rate limit exceeded after #{MAX_RETRIES} retries" if retries > MAX_RETRIES

        retry_after = response['retry-after']&.to_i || 0
        wait_time = [retry_after, retries * 10].max
        Rails.logger.info "[ImageGenerator] Rate limited, waiting #{wait_time}s (retry #{retries}/#{MAX_RETRIES})"
        sleep wait_time
        next
      end

      unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPCreated)
        raise GenerationError, "Replicate API error: #{response.code} - #{response.body}"
      end

      return JSON.parse(response.body)
    end
  end

  def poll_for_result(prediction)
    poll_url = prediction['urls']&.dig('get') || prediction['url']
    raise GenerationError, "No poll URL returned from Replicate" unless poll_url

    60.times do
      sleep 2
      uri = URI(poll_url)
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Token #{@api_token}"

      response = http_client(uri).request(request)
      result = JSON.parse(response.body)

      case result['status']
      when 'succeeded'
        output = result['output']
        return output.is_a?(Array) ? output.first : output
      when 'failed', 'canceled'
        raise GenerationError, "Generation failed: #{result['error'] || 'Unknown error'}"
      end
    end

    raise GenerationError, "Generation timed out after 120 seconds"
  end
end
