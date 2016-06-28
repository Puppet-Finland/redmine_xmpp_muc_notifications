class NotifierHook < Redmine::Hook::Listener

  def controller_issues_new_after_save(context={})
    begin
      deliver(make_msg(context[:issue], context[:issue].author.name, "created")) unless !validate_settings?
    rescue
      # we don't want to crash redmine for a damned notification
    end
  end

  def controller_issues_edit_after_save(context={})
    begin
      deliver(make_msg(context[:issue], context[:journal].user.name, "updated")) unless !validate_settings?
    rescue
      # we don't want to crash redmine for a damned notification
    end
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
    message.body = "[redmine/#{issue.project}] @#{author} #{action} issue ##{issue.id} : #{issue.subject} [#{issue.status.name}] #{redmine_url}/issues/#{issue.id}"
    # http://xmpp.org/extensions/xep-0071.html
    issue_subject_html = ERB::Util.html_escape("#{issue.subject}")
    message.xhtml_body = "<p>[redmine/#{issue.project}] @#{author} #{action} issue <a href='#{redmine_url}/issues/#{issue.id}'>##{issue.id}</a> : #{issue_subject_html} [#{issue.status.name}]</p>"
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
