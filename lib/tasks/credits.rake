namespace :credits do
  desc "Manually adjust a user's credit balance (support use)"
  task :grant, [:email, :amount] => :environment do |_, args|
    user = User.find_by!(email: args[:email])
    user.add_credits!(args[:amount].to_i, reason: 'admin_adjustment')
    puts "#{user.email} now has #{user.credits_balance} credits"
  end
end
