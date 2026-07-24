module Api
  class SupportTicketsController < BaseController
    def create
      ticket = current_user.support_tickets.build(ticket_params)

      if ticket.save
        SupportMailer.new_ticket(ticket).deliver_later
        render json: { message: "Ticket envoyé" }, status: :created
      else
        render json: { error: ticket.errors.full_messages.join(", ") }, status: :unprocessable_entity
      end
    end

    private

    def ticket_params
      params.permit(:subject, :message, :category)
    end
  end
end
