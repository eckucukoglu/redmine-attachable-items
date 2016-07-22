class ItemsController < ApplicationController
  unloadable
  before_filter :find_project_by_project_id ,:authorize
  include ItemsHelper

  def index
    @project = Project.find(params[:project_id])
    @items = Item.where(project_id: @project.id)
    @project_custom_fields = ItemsCustomField.where(project_id: @project.id)
    @histories = ItemsHistory.where(:project_id => @project.id).order("action_time ASC")
  end

  def new
    @project = Project.find(params[:project_id])
    @item = Item.new
  end

  def create
    @project = Project.find(params[:project_id])
    @item = Item.new(:project_id => @project.id, :unique_name => params[:item][:unique_name])

    if @item.save
      generateHistory(@project, "new", @item)
      flash[:success] = "Item created. Please set custom fields if exists."
      redirect_to edit_project_item_path(:project_id => @project.id, :id => @item.id)
    else
      flash.now[:alert] = "Item couldn't be created! Please check the form."
      render new_project_item_path
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    @item = Item.find_by_id_and_project_id(params[:id], @project.id)
    @project_custom_fields = ItemsCustomField.where(project_id: @project.id)
    @item_custom_values = ItemsCustomValue.where(item_id: @item.id)
  end

  def add_custom_value
    @project = Project.find(params[:project_id])
    if params[:items_custom_values] == nil
      flash[:success] = "Nothing changed for item."
      render project_items_path
    end

    @times = params[:items_custom_values].length

    params[:items_custom_values].each do |pair|

      @custom_field_id = pair[0].split('_')[1]
      @customvalue = ItemsCustomValue.find_by_item_id_and_items_custom_field_id(params[:item_id], @custom_field_id)
      if @customvalue == nil
        @customvalue = ItemsCustomValue.new(:item_id => params[:item_id],
                                             :items_custom_field_id => @custom_field_id,
                                             :value => pair[1])
        @status = @customvalue.save
        generateHistory(@project, "new", @customvalue)
      elsif @customvalue.value != pair[1]
        old_custom_value = @customvalue.value
        @status = @customvalue.update_attributes(:value => pair[1])
        generateHistory(@project, "update", @customvalue, old_custom_value)
      else
        @status = true # since no need to change.
      end

      if @status
        @times = @times - 1;
      else
        Rails.logger.info(@customvalue.errors.inspect)
      end

    end

    if @times == 0
      flash[:success] = "Item custom values set."
      redirect_to project_items_path
    else
      flash.now[:alert] = "Item custom values couldn't set! Please check the form."
      render edit_project_item_path(:project_id => params[:project_id],
                                    :id => params[:item_id])
    end

  end

  def update
    @project = Project.find(params[:project_id])
    @item = Item.find(params[:id])
    old_unique_name = @item.unique_name

    if @item.update_attributes(:unique_name => params[:item][:unique_name], :project_id => @project.id)
      generateHistory(@project, "update", @item, old_unique_name)
      flash[:success] = "Item updated."
      redirect_to project_items_path(:project_id => @project.id)
    else
      flash.now[:alert] = "Item couldn't be updated! Please check the form."
      render edit_project_item_path(:project_id => @project.id, :id => @item.id)
    end
  end

  def destroy
    @project = Project.find(params[:project_id])
    @item = Item.find(params[:id])
    @status = @item.destroy

    if @status
      generateHistory(@project, "destroy", @item)
      @customvalues = ItemsCustomValue.where(item_id: @item.id)
      @customvalues.each do |customvalue|
        customvalue.destroy
      end

      @itemsissues = ItemsIssue.where(item_id: @item.id)
      @itemsissues.each do |itemsissue|
        itemsissue.destroy
        removed_item_issue_relation = ItemsRemovedIssueRelations.new(:issue_id => itemsissue.issue_id, :item_unique_name => @item.unique_name)
        removed_item_issue_relation.save
        generateHistory(@project, "destroy", itemsissue)
      end
    end

    if @status
      flash[:success] = "Item deleted."
      redirect_to project_items_path
    else
      flash.now[:alert] = "Item couldn't be deleted!"
      render project_items_path
    end
  end

  private
  def find_project
    @project = Project.find(params[:project_id])
  end

  def require_project_member_or_admin
    if User.current.admin == true
      return true
    end

    @project_member_ids = Project.find(params[:project_id]).users.collect{|u| u.id}
    @current_login_id = User.current.id

    if @project_member_ids.include?(@current_login_id)
      return true
    else
      redirect_to :action => :index, :controller => 'projects'
      flash[:error] = "You are not a member for this project."
    return
    end
  end

end
