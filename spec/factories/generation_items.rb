FactoryBot.define do
  factory :generation_item do
    generation_batch { nil }
    prompt { "MyText" }
    position { 1 }
    status { "MyString" }
    image_url { "MyString" }
    error_message { "MyText" }
  end
end
