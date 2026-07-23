namespace :api_token do
  desc "Show the API token for a user (creates one if missing)"
  task :show, [:email] => :environment do |_, args|
    user = User.find_by!(email: args[:email])
    puts user.api_token
  end

  desc "Regenerate the API token for a user"
  task :regenerate, [:email] => :environment do |_, args|
    user = User.find_by!(email: args[:email])
    user.regenerate_api_token
    puts user.api_token
  end
end
