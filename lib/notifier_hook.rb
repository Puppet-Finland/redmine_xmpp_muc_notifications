class NotifierHook < Redmine::Hook::Listener
  
#TODO: it is plans to rename hooks in upstream
  def controller_issues_new_after_save(context={})
    redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
    issue = context[:issue]
    message = "[redmine/#{issue.project}] @#{issue.author.name} created issue ##{issue.id} #{issue.subject} #{redmine_url}/issues/#{issue.id}"
    deliver message
  end
  
  def controller_issues_edit_after_save(context={})
    redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
    issue = context[:issue]
    journal = context[:journal]
    message = "[redmine/#{issue.project}] @#{journal.user.name} updated issue ##{issue.id} #{issue.subject} #{redmine_url}/issues/#{issue.id}"
    deliver message
  end

  private

  def deliver(message)
    config = Setting.plugin_redmine_xmpp_muc_notifications
    begin
      if ( config["jid"].nil? || config["jid"] == "" \
           || config["jidpassword"].nil? || config["jidpassword"] == "" \
           || config["muc_room"].nil? || config["muc_room"] == "" \
           || config["muc_server"].nil? || config["muc_server"] == "" \
           || config["nickname"].nil? || config["nickname"] == "" )
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
    rescue
      ## Error connect XMPP or Error send message
      # RAILS_DEFAULT_LOGGER.error "XMPP Error: #{$!}"
    end
    client = nil
    muc = nil
  end
  
end
