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
      ItemsHistory.new(:project_id => @project.id,
                       :user_id => User.current.id,
                       :action_time => DateTime.now,
                       :action_type => "new",
                       :object_type => "itemscustomfield",
                       :object_id => @customfield.id,
                       :field_name => "name",
                       :old_value => "",
                       :value => @customfield.name).save
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

    if @customfield.update_attributes(:project_id => @project.id,
                                      :name => params[:customfield][:name],
                                      :field_format => params[:customfield][:field_format],
                                      :default_value => params[:customfield][:default_value])
      # TODO: journaldetail
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
    old_custom_field_id = @customfield.id
    old_custom_field_name = @customfield.name
    @status = @customfield.destroy

    if @status
      ItemsHistory.new(:project_id => @project.id,
                       :user_id => User.current.id,
                       :action_time => DateTime.now,
                       :action_type => "destroy",
                       :object_type => "itemscustomfield",
                       :object_id => old_custom_field_id,
                       :field_name => "name",
                       :old_value => old_custom_field_name,
                       :value => "").save
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
