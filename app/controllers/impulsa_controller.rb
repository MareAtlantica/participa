class ImpulsaController < ApplicationController

  before_action :authenticate_user!
  before_action :set_user_project
 
  def new
    if @edition
      redirect_to edit_impulsa_path if @project
      new_user_project
    else
      @upcoming = ImpulsaEdition.upcoming.first
      render :inactive
    end
  end

  def edit
    redirect_to new_impulsa_path unless @project
  end

  def modify
    redirect_to new_impulsa_path unless @project

    @project.assign_attributes project_params

    if params[:commit].blank?
      render 'edit'
    else
      @project.mark_for_review if params[:commit]!="Guardar cambios"
      if @project.save
        flash[:notice] = "Los cambios han sido guardados"
        redirect_to edit_impulsa_path
      end
    end
  end

  def create
    redirect_to edit_impulsa_path if @project
    new_user_project

    if params[:commit] and @project.save
      redirect_to edit_impulsa_path, notice: "El proyecto ha sido guardado."
    else
      render :new
    end
  end

  private

  def set_user_project
    @edition = ImpulsaEdition.current
    return if @edition.nil?

    @project = @edition.impulsa_projects.where(user:current_user).first 
    @available_categories = @edition.impulsa_edition_categories
    @available_categories = @available_categories.non_author if !current_user.impulsa_author?
  end

  def new_user_project
    @project = ImpulsaEdition.current.impulsa_projects.build
    @project.impulsa_edition_category = ImpulsaEdition.current.impulsa_edition_categories.first
    @project.assign_attributes(project_params) unless params[:impulsa_project].blank?
    @project.organization_type = 0 if @project.allows_organization_types? and @project.organization_type.nil?
    @project.user = current_user
  end

  def project_params
    params.require(:impulsa_project).permit(@project.user_editable_fields)
  end

end
