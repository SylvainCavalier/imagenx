FactoryBot.define do
  factory :prompt_preset do
    user { nil }
    name { "MyString" }
    prompt_text { "MyText" }
    aspect_ratio { "MyString" }
  end
end
