class ItemsController < ApplicationController
  unloadable
  before_filter :find_project_by_project_id ,:authorize

  def index
    @project = Project.find(params[:project_id])
    @items = Item.where(project_id: @project.id)
    @project_custom_fields = ItemsCustomField.where(project_id: @project.id)
  end

  def new
    @project = Project.find(params[:project_id])
    @item = Item.new
  end

  def create
    @project = Project.find(params[:project_id])
    @item = Item.new(:project_id => @project.id, :unique_name => params[:item][:unique_name])

    if @item.save
      ItemsHistory.new(:project_id => @project.id,
                       :user_id => User.current.id,
                       :action_time => DateTime.now,
                       :action_type => "new",
                       :object_type => "item",
                       :object_id => @item.id,
                       :field_name => "unique_name",
                       :old_value => "",
                       :value => @item.unique_name).save
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
        ItemsHistory.new(:project_id => @project.id,
                         :user_id => User.current.id,
                         :action_time => DateTime.now,
                         :action_type => "new",
                         :object_type => "itemscustomvalue",
                         :object_id => @customvalue.id,
                         :field_name => "value",
                         :old_value => "",
                         :value => @customvalue.value).save
      elsif @customvalue.value != pair[1]
        old_custom_value = @customvalue.value
        @status = @customvalue.update_attributes(:value => pair[1])
        ItemsHistory.new(:project_id => @project.id,
                         :user_id => User.current.id,
                         :action_time => DateTime.now,
                         :action_type => "update",
                         :object_type => "itemscustomvalue",
                         :object_id => @customvalue.id,
                         :field_name => "value",
                         :old_value => old_custom_value,
                         :value => @customvalue.value).save
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
      ItemsHistory.new(:project_id => @project.id,
                       :user_id => User.current.id,
                       :action_time => DateTime.now,
                       :action_type => "update",
                       :object_type => "item",
                       :object_id => @item.id,
                       :field_name => "unique_name",
                       :old_value => old_unique_name,
                       :value => @item.unique_name).save

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
    old_unique_name = @item.unique_name
    old_id = @item.id
    @status = @item.destroy

    if @status
      ItemsHistory.new(:project_id => @project.id,
                       :user_id => User.current.id,
                       :action_time => DateTime.now,
                       :action_type => "destroy",
                       :object_type => "item",
                       :object_id => old_id,
                       :field_name => "unique_name",
                       :old_value => old_unique_name,
                       :value => "").save

      @customvalues = ItemsCustomValue.where(item_id: @item.id)
      @customvalues.each do |customvalue|
        customvalue.destroy
      end

      @itemsissues = ItemsIssue.where(item_id: @item.id)
      @itemsissues.each do |itemissue|
        item_id = itemissue.item_id
        issue_id = itemissue.issue_id
        item_id_issue_id = item_id.to_s + "-" + issue_id.to_s
        old_itemsissue_id = itemissue.id
        itemissue.destroy
        ItemsHistory.new(:project_id => @project.id,
                         :user_id => User.current.id,
                         :action_time => DateTime.now,
                         :action_type => "destroy",
                         :object_type => "itemsissue",
                         :object_id => old_itemsissue_id,
                         :field_name => "item_id-issue_id",
                         :old_value => item_id_issue_id,
                         :value => "").save
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
