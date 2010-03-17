---
layout: page
title: Mutt with msmtp and offlineimap
published: false
---

[Mutt] is a console based mail reading client.  I've seen it used by a few uber-geeks, and I wanted to give it a try.  After a week or so, I'm hooked.  It can be used a few different ways.

I have three different email accounts:
+ School departmental email for engineering
+ Generic school email
+ Shared gmail account with the wife

All of them get used by me for different purposes.  I've tried using many different mail clients in the past, including [Thunderbird], [Claws-mail], and using [Gmail] as a hub with everything else forwarding there.  Each has its advantages and disadvantages.

In the end, I've settled on my current setup for several different reasons:
+ Both my computers (laptop and home desktop) have a copy of my email available, so I don't need to be online to see or compose email that already synced (you do need to be online to sync or send, of course).
+ Configuring things in text files makes things much easier to configure (in my opinion).
+ [Easy PGP integration] with [GnuPG].
+ Geek cred (perhaps the _true_ reason).

Anyway, I will walk through installing mutt in this fashion.  If you're interesting in how to acutally use mutt, "[My first mutt]" is a good place to start.

For this tutorial, I don't walk through everything, there are many different blogs which discuss different aspects of integrating mutt, msmtprc, and offlineimap.  I will give my configuration files as examples which I hope will suppliment already existing material.

### msmtp configuration ###

{% highlight bash %}
# The following are default values for all accounts
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile ~/.msmtp.log
syslog off

account department_mail
host smtp.department_mail.com
port 25
from me@department_mail.wsu.edu
auth on
user me@department_mail.wsu.edu
password supersecret

account school
host smtp.school.com
port 25
auth on
user me@school
password topsecret

account gmail
host smtp.gmail.com          
port 587                     
from user.name@gmail.com   
auth on                     
user user.name        
password above-topsecret       

account default : department_mail
{% endhighlight %}

### offlineimap configuration ###

I have a few folder-renamings here, in gmail and my school mail.  I also ignore a few silly folders that have absolutely nothing to do with email, and would clutter my folderlist.

{% highlight bash %}
[general]
metadata = ~/.offlineimap
accounts = department_mail,gmail,school
maxxyncaccounts = 4
socktimeout = 60
ui = TTY.TTYUI


[Account department_mail]
localrepository = local-department_mail
remoterepository = remote-department_mail

[Account gmail]
localrepository = local-gmail
remoterepository = remote-gmail

[Account school]
localrepository = local-school
remoterepository = remote-school


[Repository local-department_mail]
type = Maildir
localfolders = /home/user/.mail/department_mail

[Repository remote-department_mail]
type = IMAP
remotehost = department_mail.com
remoteuser = me@department_mail.com
remotepass = supersecret
ssl = yes
realdelete = yes

nametrans = lambda foldername: re.sub (' ', '_', foldername.lower())

folderfilter = lambda foldername: foldername not in ['Chats', 'Contacts', 'Emailed Contacts', 'Queue']


[Repository local-school]
type = Maildir
localfolders = /home/user/.mail/school

[Repository remote-school]
type = IMAP
remotehost = school.com
remoteuser = me@school.com
remotepass = topsecret
ssl = yes
realdelete = yes

nametrans = lambda foldername: re.sub ('junk_e-mail', 'spam',
			       re.sub (' ', '_', foldername.lower()))
folderfilter = lambda foldername: foldername not in ['Calendar','Contacts','Deleted Items','Journal','Outbox','Sent Items','Tasks','Notes', 'Queue']


[Repository local-gmail]
type = Maildir
localfolders = /home/user/.mail/gmail


[Repository remote-gmail]
type = Gmail
remotehost = imap.gmail.com
remoteuser = user.name@gmail.com
remotepass = above-topsecret
ssl = yes
realdelete = no
nametrans = lambda foldername: re.sub ('^\[gmail\]', 'bak',
                               re.sub ('sent_mail', 'sent',
                               re.sub ('starred', 'flagged',
                               re.sub (' ', '_', foldername.lower()))))

folderfilter = lambda foldername: foldername not in ['[Gmail]/All Mail']
{% endhighlight %}

### mutt configuration ###

I have my mutt configuration stretched across several files.



[Gmail]:http://www.gmail.com
[Mutt]:http://www.mutt.org/
[Thunderbird]:http://www.mozillamessaging.com/en-US/thunderbird/
[Claws-mail]:http://www.claws-mail.org/
[Easy PGP integration]:http://codesorcery.net/old/mutt/mutt-gnupg-howto
[GnuPG]:http://www.gnupg.org/
[My first mutt]:http://mutt.blackfish.org.uk/
