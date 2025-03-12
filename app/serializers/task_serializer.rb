# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id          :bigint           not null, primary key
#  description :string
#  status      :string           default("new"), not null
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint           not null
#
# Indexes
#
#  index_tasks_on_project_id  (project_id)
#  index_tasks_on_status      (status)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
class TaskSerializer < ApplicationSerializer
  attributes :title, :description, :status, :created_at, :updated_at
end
