class ItemsHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => "items/issues_attach_item"
  render_on :view_issues_show_description_bottom, :partial => "items/issues_show_item"

  def controller_issues_new_after_save(context={})
    @item_id = context[:params][:items][:item_id]
    @issue_id = context[:issue][:id]

    @itemsissue = ItemsIssues.find_by_issues_id(@issue_id)
    if @itemsissue == nil
      @itemsissue = ItemsIssues.new(:items_id => @item_id, :issues_id => @issue_id)
      @status = @itemsissue.save
    else
      @status = @itemsissue.update_attributes(:items_id => @item_id)
    end

    unless @status
      Rails.logger.info(@itemsissue.errors.inspect)
    end

    return ''
  end

  alias_method :controller_issues_edit_after_save, :controller_issues_new_after_save
end
