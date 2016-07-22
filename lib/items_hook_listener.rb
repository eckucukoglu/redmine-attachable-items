require_relative "../app/helpers/items_helper"

class ItemsHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => "items/issues_attach_item"
  render_on :view_issues_show_details_bottom, :partial => "items/issues_show_item"
  include ItemsHelper

  def controller_issues_new_after_save(context={})
    @project = Project.find(context[:issue][:project_id])
    if @project.module_enabled?("items") == true
      @item_ids = context[:params][:items][:item_ids]
      @itemsissues = ItemsIssue.where(issue_id: context[:issue][:id])

      if @item_ids != nil
        @item_ids.each do |item_id|
          if item_id != ""
            @issue_id = context[:issue][:id]
            @itemsissue = ItemsIssue.find_by_issue_id_and_item_id(@issue_id, item_id)
            if @itemsissue == nil
              @itemsissue = ItemsIssue.new(:item_id => item_id, :issue_id => @issue_id)
              @status = @itemsissue.save
              generateHistory(@project, "new", @itemsissue)
            end

            unless @status
              Rails.logger.info(@itemsissue.errors.inspect)
            end

          end # item_id != ""
        end # iterator for item_ids
      end # item_ids not nil

      if @itemsissues != nil
        @itemsissues.each do |itemsissue|
          @isExist = false
          @item_ids.each do |item_id|
            if item_id.to_i == itemsissue.item_id.to_i
              @isExist = true
              break
            end
          end

          unless @isExist
            itemsissue.destroy
            generateHistory(@project, "destroy", itemsissue)
          end

        end
      end


    end # module enabled

    return ''
  end

  alias_method :controller_issues_edit_after_save, :controller_issues_new_after_save
end
