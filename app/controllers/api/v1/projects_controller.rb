# frozen_string_literal: true

class Api::V1::ProjectsController < ApplicationController
  before_action :set_project, only: %i[show update destroy]

  def index
    projects = current_user.projects.includes(:tasks)

    if params[:project_ids].present?
      project_ids = params[:project_ids].is_a?(String) ? params[:project_ids].split(',') : params[:project_ids]
      projects = projects.where(id: project_ids.map(&:to_i))
    end

    render jsonapi: projects
  end

  def show
    render jsonapi: @project
  end

  def create
    project = current_user.projects.build(project_params)
    if project.save
      render jsonapi: project, status: :created
    else
      render jsonapi_errors: project.errors, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      render jsonapi: @project
    else
      render jsonapi_errors: @project.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy!
    head :no_content
  end

  private

  def set_project
    @project = current_user.projects.find_by(id: params[:id])
    head :not_found unless @project
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end

  def jsonapi_include
    super & ['tasks']
  end
end
