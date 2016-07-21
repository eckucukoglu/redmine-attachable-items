module ItemsHelper
  def generateHistory (project, action_type, object, old_value_if_updated = "", updated_field = "")
    project_id = project.id
    object_type = object.class.name.to_s
    object_id = object.id

    if object.instance_of? Item
      field_name = "unique_name"
    elsif object.instance_of? ItemsCustomField
      field_name = "name"
      if action_type == "update"
        field_name = updated_field
      end
    elsif object.instance_of? ItemsCustomValue
      field_name = "value"
    elsif object.instance_of? ItemsIssue
      field_name = "item_id-issue_id"
      item_id = object.item_id
      issue_id = object.issue_id
      item_issue_id = item_id.to_s + "-" + issue_id.to_s
    else
      return false
    end

    if action_type == "new"
      if object.instance_of? ItemsIssue
        value = item_issue_id
      else
        value = object[field_name]
      end
    elsif action_type == "update"
      old_value = old_value_if_updated
      value = object[field_name]
    elsif action_type == "destroy"
      if object.instance_of? ItemsIssue
        old_value = item_issue_id
      else
        old_value = object[field_name]
      end
    else
      return false
    end

    status = ItemsHistory.new(:project_id => project_id,
                              :user_id => User.current.id,
                              :action_time => DateTime.now,
                              :action_type => action_type,
                              :object_type => object_type,
                              :object_id => object_id,
                              :field_name => field_name,
                              :old_value => old_value,
                              :value => value).save
    return status
  end

  def getHistoryText (history)
    return history.user_id
    # user_id
    # action_time
    # action_type
    # object_type
    # object_id
    # field_name
    # old_value
    # value
  end

end
