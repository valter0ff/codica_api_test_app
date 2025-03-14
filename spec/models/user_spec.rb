# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  authentication_token   :string(30)
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

RSpec.describe User, type: :model do
  subject(:user) { create(:user) }

  describe 'database columns exists' do
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:encrypted_password).of_type(:string) }
    it { is_expected.to have_db_column(:authentication_token).of_type(:string) }
  end

  describe 'database indexes exists' do
    it { is_expected.to have_db_index(:email) }
    it { is_expected.to have_db_index(:authentication_token) }
    it { is_expected.to have_db_index(:reset_password_token) }
  end
end
