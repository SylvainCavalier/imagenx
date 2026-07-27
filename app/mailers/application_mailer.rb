class ApplicationMailer < ActionMailer::Base
  # The sending domain verified on Sweego is `mail.imagenx.fr` (the apex `imagenx.fr`
  # is NOT declared there) — any other From is rejected with "550 Unknow domain".
  default from: ENV.fetch("MAILER_FROM", "noreply@mail.imagenx.fr")
  layout "mailer"
end
