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
    htmltext = ""
    user = User.find_by_id(history.user_id)
    if user != nil
      username = user.firstname + " " + user.lastname
    else
      username = "unknown user (" + history.user_id + ")"
    end

    if history.action_type == "new"
      htmltext += "<td><font color='green'><b>" + "New " + "</b></font></td><td><b>" + history.object_type + "</b> (id:" + history.object_id.to_s + ")</td><td>"

      if history.object_type == "Item" || history.object_type == "ItemsCustomField"
        htmltext += " created with name " + history.value
      elsif history.object_type == "ItemsCustomValue"
        icv = ItemsCustomValue.find_by_id(history.object_id)
        if icv != nil
          item = Item.find_by_id(icv.item_id)
          icf = ItemsCustomField.find_by_id(icv.items_custom_field_id)

          if item != nil
            item_unique_name = item.unique_name
          else
            item_unique_name = "unknown item (" + icv.item_id + ")"
          end

          if icf != nil
            icf_name = icf.name
          else
            icf_name = "unknown custom field (" + icv.items_custom_field_id + ")"
          end
        else
          item_unique_name = "unknown item"
          icf_name = "unknown custom field"
        end

        htmltext += " saved for " + item_unique_name + "'s " + icf_name + " field with value " + history.value
      elsif history.object_type == "ItemsIssue"
        item_issue_id = history.value.split("-")
        item = Item.find_by_id(item_issue_id[0])
        issue = Issue.find_by_id(item_issue_id[1])

        if item != nil
          item_unique_name = item.unique_name
        else
          item_unique_name = "unknown item (" + item_issue_id[0] +")"
        end

        if issue != nil
          issue_subject = issue.subject
        else
          issue_subject = "unknown issue (" + item_issue_id[1] + ")"
        end

        htmltext += " relation created between " + issue_subject + " and " + item_unique_name
      else
        return ""
      end
    elsif history.action_type == "update"
      htmltext += "<td><font color='blue'><b>" + "Update on " + "</b></font></td><td><b>" + history.object_type + "</b>(" + history.object_id.to_s + ")</td><td>"
      htmltext += " changed " + history.field_name + " from " + history.old_value + " to " + history.value

    elsif history.action_type == "destroy"
      htmltext += "<td><font color='red'><b>" + "Deleted " + "</b></font></td><td><b>" + history.object_type + "</b>(" + history.object_id.to_s + ")</td><td>"

      if history.object_type == "Items" || history.object_type == "ItemsCustomField"
        htmltext += " that was named as " + history.old_value
      elsif history.object_type == "ItemsIssue"
        item_issue_id = history.old_value.split("-")
        item = Item.find_by_id(item_issue_id[0])
        issue = Issue.find_by_id(item_issue_id[1])

        if item != nil
          item_unique_name = item.unique_name
        else
          item_unique_name = "unknown item (" + item_issue_id[0] +")"
        end

        if issue != nil
          issue_subject = issue.subject
        else
          issue_subject = "unknown issue (" + item_issue_id[1] + ")"
        end

        htmltext += " relation between " + issue_subject + " and " + item_unique_name
      else
        return ""
      end


    else
      return ""
    end
    htmltext += "<td> by <b>" + username + "</b></td><td> on <b>" + Time.parse(history.action_time.to_s).utc.localtime.strftime("%m/%d/%Y %I:%M %p") + "</b>.</td>"
    render html: htmltext.html_safe
  end
end
