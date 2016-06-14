class NotifierHook < Redmine::Hook::Listener
  
#TODO: it is plans to rename hooks in upstream
  def controller_issues_new_after_save(context={})
    redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
    issue = context[:issue]

    text = l(:xmpp_issue_created) + " ##{issue.id}\n\n"
    text += l(:field_author) + ": #{issue.author.name}\n" 
    text += l(:field_subject) + ": #{issue.subject}\n"
    text += l(:field_url) + ": #{redmine_url}/issues/#{issue.id}\n"
    text += l(:field_project) + ": #{issue.project}\n"
    text += l(:field_tracker) + ": #{issue.tracker.name}\n"
    text += l(:field_priority) + ": #{issue.priority.name}\n"
    if issue.assigned_to
      text += l(:field_assigned_to) + ": #{issue.assigned_to.name}\n"
    end
    if issue.start_date
      text += l(:field_start_date) + ": #{issue.start_date.strftime("%d.%m.%Y")}\n"
    end
    if issue.due_date
      text += l(:field_due_date) + ": #{issue.due_date.strftime("%d.%m.%Y")}\n"
    end
    if issue.estimated_hours
      text += l(:field_estimated_hours) + ": #{issue.estimated_hours} " + l(:field_hours) + "\n"
    end
    if issue.done_ratio
      text += l(:field_done_ratio) + ": #{issue.done_ratio}%\n"
    end
    if issue.status
      text += l(:field_status) + ": #{issue.status.name}\n"
    end
    text += "\n\n#{issue.description}"

    deliver text, issue
  end
  
  def controller_issues_edit_after_save(context={})
    redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
    issue = context[:issue]
    journal = context[:journal]

    text = l(:xmpp_issue_updated) + " ##{issue.id}\n\n"
    text += l(:xmpp_update_author) + ": #{journal.user.name}\n"
    text += l(:field_subject) + ": #{issue.subject}\n"
    text += l(:field_url) + ": #{redmine_url}/issues/#{issue.id}\n"
    text += l(:field_project) + ": #{issue.project}\n"
    text += l(:field_tracker) + ": #{issue.tracker.name}\n"
    text += l(:field_priority) + ": #{issue.priority.name}\n"
    if issue.assigned_to
      text += l(:field_assigned_to) + ": #{issue.assigned_to.name}\n"
    end
    if issue.start_date
      text += l(:field_start_date) + ": #{issue.start_date.strftime("%d.%m.%Y")}\n"
    end
    if issue.due_date
      text += l(:field_due_date) + ": #{issue.due_date.strftime("%d.%m.%Y")}\n"
    end
    if issue.estimated_hours
      text += l(:field_estimated_hours) + ": #{issue.estimated_hours} " + l(:field_hours) + "\n"
    end
    if issue.done_ratio
      text += l(:field_done_ratio) + ": #{issue.done_ratio}%\n"
    end
    if issue.status
      text += l(:field_status) + ": #{issue.status.name}\n"
    end
    text += "\n\n#{journal.notes}"

    deliver text, issue
  end
  
  private
  
  def deliver(message, issue)
    config = Setting.plugin_redmine_xmpp_notifications
    begin
      
      if ( config["jid"].nil? || config["jid"] == "" \
           config["jidpassword"].nil? || config["jidpassword"] == "" \
           config["muc_room"].nil? || config["muc_room"] == "" \
           config["muc_server"].nil? || config["muc_server"] == "" \
           config["nickname"].nil? || config["nickname"] == "" )
        return
      end
      
      # See https://github.com/xmpp4r/xmpp4r/blob/master/data/doc/xmpp4r/examples/basic/mucsimplebot.rb
      client = Jabber::Client.new(Jabber::JID.new(config["jid"]))
      client.connect
      client.auth(config["jidpassword"])
      
      muc = Jabber::MUC::SimpleMUCClient.new(client)
      room_jid = "#{config["muc_room"]}@#{config["muc_server"]}/#{config["nickname"]}"
      muc.join(room_jid)
      
      muc.send Jabber::Message.new(muc.room, message)
    end
    rescue
      ## Error connect XMPP or Error send message
      # RAILS_DEFAULT_LOGGER.error "XMPP Error: #{$!}"
    end
    client = nil
    muc = nil
  end
  
end
