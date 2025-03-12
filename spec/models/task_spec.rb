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
RSpec.describe Task, type: :model do
  subject(:task) { create(:task) }

  describe 'database columns exists' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }
  end

  describe 'database indexes exists' do
    it { is_expected.to have_db_index(:project_id) }
    it { is_expected.to have_db_index(:status) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end
end
