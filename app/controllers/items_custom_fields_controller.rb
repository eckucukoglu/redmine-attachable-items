class ItemsCustomFieldsController < ApplicationController
  unloadable
  before_filter :find_project_by_project_id ,:authorize

  def new
    @project = Project.find(params[:project_id])
    @customfield = ItemsCustomFields.new
  end

  def create
    @project = Project.find(params[:project_id])
    @customfield = ItemsCustomFields.new(:project_id => @project.id,
                                         :name => params[:customfield][:name],
                                         :field_format => params[:customfield][:field_format],
                                         :default_value => params[:customfield][:default_value])


    if @customfield.save
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
    @customfield = ItemsCustomFields.find(params[:id])
  end

  def update
    @project = Project.find(params[:project_id])
    @customfield = ItemsCustomFields.find(params[:id])

    if @customfield.update_attributes(:project_id => @project.id,
                                      :name => params[:customfield][:name],
                                      :field_format => params[:customfield][:field_format],
                                      :default_value => params[:customfield][:default_value])
      flash[:success] = "Custom field updated."
      redirect_to project_items_path(:project_id => @project.id)
    else
      Rails.logger.info(@customfield.errors.inspect)
      flash.now[:alert] = "Custom field couldn't be updated! Please check the form."
      render project_items_path(:project_id => @project.id)
    end
  end

  def destroy
    @customfield = ItemsCustomFields.find(params[:id])

    @status = @customfield.destroy

    if @status
      @customvalues = ItemsCustomValues.find(:all).select {|i| i.items_custom_fields_id == @customfield.id }
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
