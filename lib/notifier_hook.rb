class NotifierHook < Redmine::Hook::Listener

  def controller_issues_new_after_save(context={})
    deliver(make_msg(context[:issue], context[:issue].author.name, "created")) unless !validate_settings?
  end

  def controller_issues_edit_before_save(context={})
    issue = context[:issue]
    @before_status = issue.status.name
  end

  def controller_issues_edit_after_save(context={})
    issue = context[:issue]
    @after_status = issue.status.name

    action = "updated"
    if @before_status != @after_status
      if @after_status == "Closed"
        action = "closed"
      else if @after_status == "Resolved"
        action = "resolved"
      else if @after_status == "Rejected"
        action = "rejected"
      else if @after_status == "In Progress"
        action = "reopened"
      end
    end

    deliver(make_msg(context[:issue], context[:journal].user.name, action)) unless !validate_settings?
  end

  private

  def settings
    @settings ||= Setting.plugin_redmine_xmpp_muc_notifications
  end

  def validate_settings?
    settings["jid"].present? && settings["jidpassword"].present? && settings["muc_room"].present?  && settings["muc_server"].present?  && settings["nickname"].present?
  end

  def make_msg(issue, author, action, description="")
    redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
    message = Jabber::Message.new
    message.type = "groupchat"
    message.body = "[redmine/#{issue.project}] @#{author} #{action} issue ##{issue.id} : #{issue.subject} #{redmine_url}/issues/#{issue.id}"
    # http://xmpp.org/extensions/xep-0071.html
    message.xhtml_body = "<p>[redmine/#{issue.project}] @#{author} #{action} issue <a href='#{redmine_url}/issues/#{issue.id}'>##{issue.id}</a> : #{issue.subject}</p>"
    return message
  end

  def make_client()
    client = Jabber::Client.new(Jabber::JID.new(settings["jid"]))
    client.connect
    client.auth(settings["jidpassword"])
    yield client
  ensure
    client.close
  end

  def make_muc(client)
    muc = Jabber::MUC::SimpleMUCClient.new(client)
    muc.join("#{settings["muc_room"]}@#{settings["muc_server"]}/#{settings["nickname"]}")
    yield muc
  ensure
    muc.exit
  end

  def deliver(message)
    begin
      # See https://github.com/xmpp4r/xmpp4r/blob/master/data/doc/xmpp4r/examples/basic/mucsimplebot.rb
      make_client do |client|
        make_muc(client) do |muc|
          muc.send(message)
        end
      end
    rescue
      ## Error connect XMPP or Error send message
      # RAILS_DEFAULT_LOGGER.error "XMPP Error: #{$!}"
    end
  end
  
end
