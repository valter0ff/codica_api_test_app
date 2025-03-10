# frozen_string_literal: true

if Rails.env.development?
  require 'factory_bot_rails'

  module FactoryBotConsoleMethods
    include FactoryBot::Syntax::Methods

    # This module can be customized with additional helpers
    def create_user
      create(:user)
    end
  end

  module Rails::ConsoleMethods
    include FactoryBot::Syntax::Methods
  end
end
