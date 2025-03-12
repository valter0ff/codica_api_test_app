# frozen_string_literal: true

# == Schema Information
#
# Table name: projects
#
#  id          :bigint           not null, primary key
#  description :string
#  title       :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_projects_on_user_id            (user_id)
#  index_projects_on_user_id_and_title  (user_id,title) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :project do
    title { Faker::Lorem.unique.word }
    description { Faker::Lorem.unique.sentence }
    user

    transient do
      tasks_count { 2 }
    end

    trait :with_tasks do
      tasks { build_list(:task, tasks_count) }
    end
  end
end
