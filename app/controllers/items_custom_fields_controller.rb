class ItemsCustomFieldsController < ApplicationController
  unloadable
  before_filter :find_project_by_project_id ,:authorize
  
  def new
    @project = Project.find(params[:project_id])
    @customfield = ItemsCustomField.new
  end

  def create
    @project = Project.find(params[:project_id])
    @customfield = ItemsCustomField.new(:project_id => @project.id,
                                         :name => params[:customfield][:name],
                                         :field_format => params[:customfield][:field_format],
                                         :default_value => params[:customfield][:default_value])


    if @customfield.save
      generateHistory(@project, "new", @customfield)
      flash[:success] = "Custom field created."
      redirect_to project_items_path
    else
      flash.now[:alert] = "Custom field couldn't be created! Please check the form."
      Rails.logger.info(@customfield.errors.inspect)
      render project_items_path
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    @customfield = ItemsCustomField.find(params[:id])
  end

  def update
    @project = Project.find(params[:project_id])
    @customfield = ItemsCustomField.find(params[:id])
    name = @customfield.name
    field_format = @customfield.field_format
    default_value = @customfield.default_value

    if @customfield.update_attributes(:project_id => @project.id,
      :name => params[:customfield][:name],
      :field_format => params[:customfield][:field_format],
      :default_value => params[:customfield][:default_value])

      if name != params[:customfield][:name]
        generateHistory(@project, "update", @customfield, name, :name)
      end

      if field_format != params[:customfield][:field_format]
        generateHistory(@project, "update", @customfield, field_format, :field_format)
      end

      if default_value != params[:customfield][:default_value]
        generateHistory(@project, "update", @customfield, default_value, :default_value)
      end

      flash[:success] = "Custom field updated."
      redirect_to project_items_path(:project_id => @project.id)
    else
      Rails.logger.info(@customfield.errors.inspect)
      flash.now[:alert] = "Custom field couldn't be updated! Please check the form."
      render project_items_path(:project_id => @project.id)
    end
  end

  def destroy
    @project = Project.find(params[:project_id])
    @customfield = ItemsCustomField.find(params[:id])
    @status = @customfield.destroy

    if @status
      generateHistory(@project, "destroy", @customfield)
      @customvalues = ItemsCustomValue.where(items_custom_field_id: @customfield.id)
      @customvalues.each do |customvalue|
        customvalue.destroy
      end
    end

    if @status
      flash[:success] = "Custom field deleted."
      redirect_to project_items_path
    else
      flash.now[:alert] = "Custom field couldn't be deleted!"
      render project_items_path
    end
  end

end
