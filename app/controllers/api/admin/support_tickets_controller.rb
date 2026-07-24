module Api
  module Admin
    class SupportTicketsController < BaseController
      def index
        scope = SupportTicket.includes(:user).recent.by_status(params[:status])
        pagy, records = pagy(scope, items: params[:per_page] || 25)

        render json: {
          records: records.map { |t| ticket_admin_json(t) },
          pagy: { page: pagy.page, pages: pagy.pages, count: pagy.count }
        }
      end

      def update
        ticket = SupportTicket.find(params[:id])
        if ticket.update(ticket_params)
          render json: { ticket: ticket_admin_json(ticket) }
        else
          render json: { error: ticket.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      def destroy
        SupportTicket.find(params[:id]).destroy
        head :no_content
      end

      private

      def ticket_params
        params.permit(:status, :admin_notes)
      end

      def ticket_admin_json(ticket)
        {
          id: ticket.id,
          subject: ticket.subject,
          message: ticket.message,
          category: ticket.category,
          status: ticket.status,
          admin_notes: ticket.admin_notes,
          created_at: ticket.created_at,
          user: { id: ticket.user.id, email: ticket.user.email, name: ticket.user.name }
        }
      end
    end
  end
end
