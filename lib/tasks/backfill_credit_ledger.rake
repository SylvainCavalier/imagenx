# One-off data fix: users created before the credit ledger existed have a
# credits_balance with no corresponding credit_transactions row. This inserts one
# admin_adjustment row per such user so the ledger reconciles with the balance
# from day one. Safe to re-run — only touches users with zero ledger rows.
namespace :credits do
  desc "Backfill a ledger row for users whose credits_balance predates the ledger"
  task backfill_ledger: :environment do
    users = User.left_joins(:credit_transactions).where(credit_transactions: { id: nil })

    users.find_each do |user|
      next if user.credits_balance.zero?

      user.credit_transactions.create!(
        amount: user.credits_balance,
        balance_after: user.credits_balance,
        reason: "admin_adjustment",
        metadata: { note: "backfill: pre-ledger balance" }
      )
      puts "Backfilled #{user.email}: #{user.credits_balance} credits"
    end
  end
end
