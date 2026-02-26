FactoryBot.define do
  factory :generation_batch do
    user { nil }
    main_prompt { "MyText" }
    aspect_ratio { "MyString" }
    status { "MyString" }
  end
end
