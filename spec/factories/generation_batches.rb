# == Schema Information
#
# Table name: generation_batches
#
#  id            :bigint           not null, primary key
#  aspect_ratio  :string
#  main_prompt   :text
#  status        :string           default("pending"), not null
#  style_options :jsonb            not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
#
# Indexes
#
#  index_generation_batches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :generation_batch do
    association :user
    main_prompt { "A cinematic photograph" }
    aspect_ratio { "1:1" }
    status { "pending" }
  end
end
