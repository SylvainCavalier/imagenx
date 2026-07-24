namespace :credits do
  desc "Manually adjust a user's credit balance (support use)"
  task :grant, [:email, :amount] => :environment do |_, args|
    user = User.find_by!(email: args[:email])
    user.increment!(:credits_balance, args[:amount].to_i)
    puts "#{user.email} now has #{user.credits_balance} credits"
  end
end
