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
class Task < ApplicationRecord
  belongs_to :project

  enum :status, { new: 'new', in_progress: 'in_progress', completed: 'completed' }, prefix: true, validate: true

  validates :title, presence: true
  # validates :status, presence: true, inclusion: { in: statuses.keys }
end
