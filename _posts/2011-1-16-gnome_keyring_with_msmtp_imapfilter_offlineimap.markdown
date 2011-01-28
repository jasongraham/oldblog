---
layout: post
title: Using Gnome Keyring with msmtp, offlineimap, and imapfilter via cron
time: '10:40'
tags: [email, passwords, gnome-keyring, msmtp, offlineiamp, imapfilter, cron]
---

**Update Jan 27th, 2011**: Added portion relavent to cron.  It's down at the
[bottom of the page][].
{: .update}

[bottom of the page]:#cron

In my [previous post][], I walked through setting up using [mutt][], [msmtp][], [offlineimap][], [imapfilter][], and [archivemail][] to work together.  As I wrote the post, I was reminded of how bothered I felt about having passwords for my email accounts in my configuration files.  For a single user computer, this isn't a huge problem, but I would still prefer keep my passwords out of plain text.

[previous post]:/2011/01/10/email_with_mutt_offlineimap_imapfilter_msmtp_archivemail/
[mutt]:http://www.mutt.org/
[msmtp]:http://msmtp.sourceforge.net/
[offlineimap]:https://github.com/jgoerzen/offlineimap/wiki
[imapfilter]:http://imapfilter.hellug.gr/
[archivemail]:http://archivemail.sourceforge.net/

Some searching online lead me to decide to use some pre-existing integration done using [gnome keyring][], which lets your store passwords in an encrypted form.

[gnome keyring]:http://en.wikipedia.org/wiki/GNOME_Keyring

A gnome-keyring patch for msmtp has [already been integrated][msmtp-gnome] into the `msmtp-gnome` package in the repositories, and a nice [script][msmtp-keyring-script] to add the appropriate data to the keyring exists.  Another great post I found explains how to [integrate offlineimap with gnome-keyring][offlineimap-gnome-keyring] with a python helper script.  It defines a couple functions that can pull the username and password directly within the configuration file.  I've updated my own configuration files and tutorial in the previous post.

[msmtp-gnome]:http://simple-and-basic.com/2008/10/using-msmtp-with-the-gnome-keyring.html
[msmtp-keyring-script]:https://github.com/gaizka/misc-scripts/raw/master/msmtp/msmtp-gnome-tool.py
[offlineimap-gnome-keyring]:http://www.clasohm.com/blog/one-entry?entry_id=90957

I didn't find any examples of using imapfilter with gnome-keyring, but I was reminded after seeing the [example extended settings file][imapfilter-ext-config] that since the configuration files are actually Lua scripts, we can use a slightly modified version of the python helper script used with offlineimap, and then simply pipe the input into the settings file to clean up.

[imapfilter-ext-config]:http://imapfilter.hellug.gr/sample.extend.lua.txt

{% highlight python %}
#!/usr/bin/python
"""
File: imapfilter.py

Used to grab IMAP password information from
Gnome-Keyring.

Usage:
   ./imapfilter.py SERVER_NAME INFO

   where INFO is either "user" or "password", depending
   on the information you want.
"""

import sys
import gtk
import gnomekeyring as gkey

class Keyring(object):
    def __init__(self, name, server, protocol):
        self._name = name
        self._server = server
        self._protocol = protocol
        self._keyring = gkey.get_default_keyring_sync()

    def has_credentials(self):
        try:
            attrs = {"server": self._server, "protocol": self._protocol}
            items = gkey.find_items_sync(gkey.ITEM_NETWORK_PASSWORD, attrs)
            return len(items) > 0
        except gkey.DeniedError:
            return False

    def get_credentials(self):
        attrs = {"server": self._server, "protocol": self._protocol}
        items = gkey.find_items_sync(gkey.ITEM_NETWORK_PASSWORD, attrs)
        return (items[0].attributes["user"], items[0].secret)

    def set_credentials(self, (user, pw)):
        attrs = {
                "user": user,
                "server": self._server,
                "protocol": self._protocol,
            }
        gkey.item_create_sync(gkey.get_default_keyring_sync(),
                gkey.ITEM_NETWORK_PASSWORD, self._name, attrs, pw, True)

def main(server, info):
    keyring = Keyring("offlineimap " + server, server, "imap")
    (username, password) = keyring.get_credentials()

    if info == "user":
        print(username)
    elif info == "password":
        print(password)
    else: # neither user nor pass
        sys.exit(-2)

if __name__ == '__main__':
    server = sys.argv[1]
    info = sys.argv[2]
    main(server, info)
{% endhighlight %}

{% highlight lua %}
-------------------------------------
-- Partial Imapfilter configuration
-- example.lua
-------------------------------------

-- Function strips trailing newlines
-- piped back from imapfilter.py
function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- extract username and password from gnome-keyring
status, myuser = pipe_from('/path/to/imapfilter.py mail.example.com user')
myuser = trim(myuser)

status, mypass = pipe_from('/path/to/imapfilter.py mail.example.com password')
mypass = trim(mypass)

ACCOUNT = IMAP {
        server = 'mail.example.com',
        username = myuser,
        password = mypass,
}

{% endhighlight %}

Finally, the trick to allowing cron to access the gnome-keyring is found in
supplying it with the right environmental variables.  I found something close
[implemented in svn][] and a couple small changes let's it work with
offlineimap.
{: #cron}

[implemented in svn]:http://mud-slide.blogspot.com/2010/12/subversion-and-gnome-keyring.html

{% highlight bash %}
#!/bin/bash
# file: pullmail.sh
#
# This script may be called via a cron job to allow
# offlineimap (and imapfilter) to use the environmental
# variables to access from gnome-keyring
#
# Attaches the current BASH session to a GNOME keyring daemon
#
# Returns 0 on success 1 on failure.
#
# Example cron call: (change the times to suit)
#
#	*/10 * * * * /full/path/to/pullmail.sh > /full/path/to/logfile.txt
#
function gnome-keyring-control() {
	local -a vars=( \
		DBUS_SESSION_BUS_ADDRESS \
		GNOME_KEYRING_CONTROL \
		GNOME_KEYRING_PID \
		XDG_SESSION_COOKIE \
	)
	local pid=$(ps -C gnome-session -o pid --no-heading)
	eval "unset ${vars[@]}; $(printf "export %s;" $(sed 's/\x00/\n/g' /proc/${pid//[^0-9]/}/environ | grep $(printf -- "-e ^%s= " "${vars[@]}")) )"
}

gnome-keyring-control

/usr/bin/offlineimap -c /full/path/to/offlineimaprc -o -u Noninteractive.Basic
{% endhighlight %}

