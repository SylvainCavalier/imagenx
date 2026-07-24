# Rack::Attack configuration for rate limiting and blocking

class Rack::Attack
  # Allow requests from localhost during development
  Rack::Attack.safelist('allow-localhost') do |req|
    Rails.env.development? && ['127.0.0.1', '::1'].include?(req.ip)
  end

  # Throttle login attempts by IP address (real endpoint — devise_for :users, skip: :all
  # means the classic /users/sign_in route doesn't exist here, auth lives under /api/auth)
  Rack::Attack.throttle('login attempts by ip', limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == '/api/auth/login' && req.post?
  end

  # Throttle login attempts by email address
  Rack::Attack.throttle('login attempts by email', limit: 5, period: 60.seconds) do |req|
    if req.path == '/api/auth/login' && req.post?
      req.params['email']&.downcase
    end
  end

  # Throttle registration attempts by IP
  Rack::Attack.throttle('registration attempts by ip', limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == '/api/auth/register' && req.post?
  end

  # Throttle password reset requests
  Rack::Attack.throttle('password reset attempts by ip', limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == '/api/auth/forgot_password' && req.post?
  end

  Rack::Attack.throttle('password reset attempts by email', limit: 3, period: 60.seconds) do |req|
    if req.path == '/api/auth/forgot_password' && req.post?
      req.params['email']&.downcase
    end
  end

  # Throttle confirmation email resends
  Rack::Attack.throttle('resend confirmation attempts by ip', limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == '/api/auth/resend_confirmation' && req.post?
  end

  # Throttle API requests
  Rack::Attack.throttle('api requests', limit: 100, period: 60.seconds) do |req|
    if req.path.start_with?('/api/')
      req.ip
    end
  end

  # General request throttling
  Rack::Attack.throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Response when throttled
  self.throttled_responder = lambda do |_request|
    [429, {'Content-Type' => 'application/json'}, [{error: "Rate limit exceeded. Try again later."}.to_json]]
  end
end

# Enable Rack::Attack logging (only for throttles and blocks, not safelists)
ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, payload|
  req = payload[:request]
  match_type = payload[:match_type]
  next if match_type == :safelist

  Rails.logger.warn "[Rack::Attack] #{req.ip} #{req.request_method} #{req.fullpath} #{match_type}: #{payload[:match_discriminator]}"
end
