require "redmine"
require "rubygems"
require "xmpp4r"
require "xmpp4r/muc/helper/simplemucclient"

require_dependency "notifier_hook"

Redmine::Plugin.register :redmine_xmpp_notifications do
  name "Redmine XMPP Notifications plugin"
  author "Julien Malik, original code from Pavel Musolin & Vadim Misbakh-Soloviov"
  description "A plugin to sends Redmine Activity over a XMPP MUC"
  version "1.0.0"
  url "https://github.com/YunoHost/redmine_xmpp_muc_notifications"
  
  settings :default => {"jid" => "", "password" => "", "muc_room" => "", "muc_server" => "", "nickname" => ""}, :partial => "settings/xmpp_settings"
end
