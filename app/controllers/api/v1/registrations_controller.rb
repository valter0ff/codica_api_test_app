# frozen_string_literal: true

class Api::V1::RegistrationsController < Devise::RegistrationsController
  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: { user: resource, token: resource.authentication_token }
      }, status: :ok
    else
      render json: {
        status: { code: 422, message: "User couldn't be created. #{resource.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end
end
