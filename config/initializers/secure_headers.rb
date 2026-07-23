# SecureHeaders configuration
# This gem provides security headers to protect against XSS, clickjacking, and other attacks

SecureHeaders::Configuration.default do |config|
  # Content Security Policy
  config.csp = {
    # Fetch directives specify the valid sources for various types of content
    default_src: %w('self'),
    base_uri: %w('self'),
    child_src: %w('self'),
    connect_src: %w('self' ws: wss:),
    font_src: %w('self' https: data:),
    # Allow form submissions to self and external providers (for OAuth)
    form_action: %w('self' https:),
    frame_ancestors: %w('none'),
    frame_src: %w('self'),
    img_src: %w('self' https: data:),
    manifest_src: %w('self'),
    media_src: %w('self'),
    object_src: %w('none'),
    script_src: %w('self'),
    style_src: %w('self' 'unsafe-inline'),
    worker_src: %w('self'),
    
    # Development-specific rules for Vite
    upgrade_insecure_requests: Rails.env.production?, # Only force HTTPS in production
    report_uri: Rails.env.production? ? %w(/csp-violation-report-endpoint) : nil
  }

  # Add Vite development server support
  if Rails.env.development?
    begin
      vite_host = ViteRuby.config.host_with_port
      config.csp[:connect_src] += ["http://#{vite_host}", "ws://#{vite_host}"]
      config.csp[:script_src] += ["http://#{vite_host}", "'unsafe-eval'"]
      config.csp[:style_src] += ["http://#{vite_host}"]
    rescue => e
      Rails.logger.warn "Could not configure Vite CSP: #{e.message}"
    end
  end

  # Test environment modifications
  if Rails.env.test?
    config.csp[:script_src] += %w('unsafe-inline' 'unsafe-eval')
    config.csp[:style_src] += %w('unsafe-inline')
  end

  # HTTP Strict Transport Security - only in production
  if Rails.env.production?
    config.hsts = "max-age=31536000; includeSubDomains; preload"
  end

  # X-Frame-Options
  config.x_frame_options = 'DENY'

  # X-Content-Type-Options
  config.x_content_type_options = 'nosniff'

  # X-XSS-Protection (legacy, but still useful for older browsers)
  config.x_xss_protection = '1; mode=block'

  # Referrer Policy
  config.referrer_policy = 'strict-origin-when-cross-origin'
end

# Configuration spécifique pour Devise
# Permet les redirections et formulaires nécessaires pour l'authentification
SecureHeaders::Configuration.override(:devise_forms) do |config|
  config.csp[:form_action] = %w('self' https:)
  # Permet les scripts inline si nécessaire pour certaines fonctionnalités Devise
  # config.csp[:script_src] += ["'unsafe-inline'"] if Rails.env.development?
end

# Configuration pour les pages d'erreur et de maintenance
SecureHeaders::Configuration.override(:error_pages) do |config|
  config.csp[:style_src] += ["'unsafe-inline'"]
  config.csp[:script_src] += ["'unsafe-inline'"]
end