FactoryBot.define do
  factory :saved_image do
    image_folder { nil }
    prompt { "MyText" }
    source_url { "MyString" }
  end
end
