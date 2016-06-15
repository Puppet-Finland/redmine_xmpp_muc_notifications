# XMPP MUC Notifications Plugin for Redmine

This plugin is intended to provide basic integration with XMPP messenger (Jabber),
by sending notifications of updates to issues to a XMPP MUC (multi user chat) room.

Following actions will result in notifications to Jabber:

- Create and update issues

## Installation & Configuration

- The XMPP MUC Notifications Plugin depends on the [Xmpp4r](https://github.com/xmpp4r/xmpp4r). This can be installed with:
    $ sudo gem install xmpp4r
- Then install the Plugin following the general Redmine [plugin installation instructions](http://www.redmine.org/wiki/redmine/Plugins).
- Go to the Plugins section of the Administration page, select Configure.
- On this page fill out the Jabber ID and password for user who will sends messages, and the MUC room where to send messages to.
- Restart your Redmine web servers (e.g. mongrel, thin, mod_rails).
