class SupportMailer < ApplicationMailer
  CATEGORY_LABELS = {
    "technical" => "Support technique",
    "billing" => "Facturation et Abonnement",
    "idea" => "Boîte à idées"
  }.freeze

  def new_ticket(ticket)
    @ticket = ticket
    @user = ticket.user
    @category_label = CATEGORY_LABELS.fetch(@ticket.category, @ticket.category)

    mail(
      to: ENV.fetch("SUPPORT_EMAIL", "mail@sylvaincavalier.com"),
      reply_to: @user.email,
      subject: "[#{@category_label}] #{@ticket.subject}"
    )
  end
end
