# frozen_string_literal: true

class Api::V1::SessionsController < Devise::SessionsController
  skip_before_action :verify_signed_out_user, only: :destroy

  def destroy
    if current_user
      current_user.update_column(:authentication_token, nil) # rubocop:disable Rails/SkipsModelValidations
      render json: { status: { code: 200, message: 'Logged out successfully.' } }, status: :ok
    else
      render json: { status: { code: 401, message: 'User not found or already logged out.' } }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, _opts = {})
    resource.update(authentication_token: Devise.friendly_token) if resource.authentication_token.blank?

    render json: {
      status: { code: 200, message: 'Logged in successfully.' },
      data: { user: resource }
    }, status: :ok
  end
end
