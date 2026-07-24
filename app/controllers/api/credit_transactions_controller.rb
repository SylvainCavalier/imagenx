module Api
  class CreditTransactionsController < BaseController
    def index
      transactions = current_user.credit_transactions.recent.limit(50)
      render json: transactions.map { |t| transaction_json(t) }
    end

    private

    def transaction_json(transaction)
      {
        id: transaction.id,
        amount: transaction.amount,
        balance_after: transaction.balance_after,
        reason: transaction.reason,
        created_at: transaction.created_at
      }
    end
  end
end
