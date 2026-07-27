# Delivery job for every `deliver_later` call (wired up in config/application.rb).
#
# Confirmation and reset-password emails are the only way into an account, so a transient
# relay failure must not silently drop them. Permanent failures (550 unknown sender domain,
# bad recipient) are not retried — they need a config fix, not another attempt.
class MailDeliveryJob < ActionMailer::MailDeliveryJob
  retry_on Net::SMTPServerBusy,
           Net::OpenTimeout,
           Net::ReadTimeout,
           Errno::ECONNREFUSED,
           Errno::ECONNRESET,
           SocketError,
           IOError,
           wait: :polynomially_longer, attempts: 5
end
