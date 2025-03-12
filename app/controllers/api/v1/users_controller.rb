# frozen_string_literal: true

class Api::V1::UsersController < ApplicationController
  def show
    user = current_user.class.includes(projects: :tasks).find(current_user.id)
    render jsonapi: user
  end

  private

  def jsonapi_include
    super & ['projects', 'projects.tasks']
  end
end
