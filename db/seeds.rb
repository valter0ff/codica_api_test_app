# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

10.times do
  FactoryBot.create(:user, :with_projects, projects_count: 3,
                                           project_params: [:with_tasks],
                                           project_options: { tasks_count: 5 })
  Faker::UniqueGenerator.clear
end
