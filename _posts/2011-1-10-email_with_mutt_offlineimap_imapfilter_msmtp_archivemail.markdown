---
layout: post
title: Quick and simple email management with mutt, offlineimap, imapfilter, msmtp, and archivemail
time: '15:30'
tags: [email, howto, Linux, mutt, offlineimap, imapfilter, msmtp, archivemail]
---

After using [Gmail][] for many years, about a year ago my academic advisor introduced me to [mutt][].  I've been using it as my mail reader ever since, in combination with [offlineimap][], [imapfilter][], [msmtp][], and most recently [archivemail][].  The setup is highly customizable, incredibly fast, and since the configuration is completely in text files, I can quickly make and keep track of changes across my multiple computers with [git][].

[gmail]:http://gmail.com/
[mutt]:http://www.mutt.org/
[offlineimap]:https://github.com/jgoerzen/offlineimap/wiki
[imapfilter]:http://imapfilter.hellug.gr/
[msmtp]:http://msmtp.sourceforge.net/
[archivemail]:http://archivemail.sourceforge.net/
[git]:http://git-scm.com/

The downside of this approach is it requires a bit of time and possibly troubleshooting up-front to configure.  But as always, Google is your friend.  Several other good tutorials exist explaining how to use and configure these tools in various combinations, and I wanted to add examples from my own configuration to the mix in the hope that others find them useful.

Some would also point out that mutt really could technically do most of this by itself.  This absolutely works, but I like to have a division of labor of sorts, splitting up the fetching, sorting, sending, and reading between different programs.  After all, it is the [Unix Philosophy][].

[Unix Philosophy]:http://en.wikipedia.org/wiki/Unix_philosophy

> This is the Unix philosophy: Write programs that do one thing and do it well. Write programs to work together. --Doug McIlroy

My example setup will include two inboxes: one for school, and one for Gmail.  I have a few more mailboxes than this setup, but it's easy to extend from this as per your own needs.

+ Table of contents goes here.
{:toc}

<a href="http://www.flickr.com/photos/__olga__/2822660113/" title="Photo by __olga__ on Flickr" alt="Mailboxes: photo by __olga__"><img src="http://farm4.static.flickr.com/3149/2822660113_fef2bbc676_d.jpg" /></a>

### Preparation ###

It's easiest to keep everything together under one directory for git to keep track of.  From there, we can use symlinks or specify directly within the various commands about where the configuration files are.

{% highlight bash %}
mkdir ~/.mail_configs
mkdir ~/.mail_configs/mutt
mkdir ~/.mail_configs/imapfilter

# make this directory readable to you only
chmod -R 700 ~/.mail_configs

# make another set of folders to actually hold the local
# copy for offlineimap
mkdir ~/.mail
mkdir ~/.mail/school
mkdir ~/.mail/gmail
chmod -R 700 ~/.mail

# If you choose to use symlinks, you may create these now.
# Otherwise, igore this portion.
ln -s ~/.mail_configs/mutt ~/.mutt
ln -s ~/.mail_configs/msmptrc ~/.msmtprc
ln -s ~/.mail_configs/offlineimaprc ~/.offlineimaprc
ln -s ~/.mail_configs/imapfilter ~/.imapfilter
{% endhighlight %}

I assume that your configuration files and mail directories are set up like this, but if you choose to deviate from this, simply change any appropriate lines in the configuration files.

On a Debian based system, all of these programs are available from your distribution's repositories.

{% highlight bash %}
sudo apt-get install mutt offlineimap imapfilter msmtp-mta archivemail
{% endhighlight %}

### Syncing mail with Offlineimap ###

[Offlineimap][] uses the [IMAP][] protocol to synchronize a local copy of all your email messages for multiple accounts in a [maildir][] format.  Having your email be local means that reading is fast, since the email has already been downloaded to your machine.  Any changes you make such as deleting, changing flags (important, read, unread,...), or moving the email to a different folder are performed on the local copy, which is periodically synchronized with the remote copy.

[imap]:http://en.wikipedia.org/wiki/Internet_Message_Access_Protocol
[maildir]:http://en.wikipedia.org/wiki/Maildir

A [fully annotated configuration file][offlineimap_full_example_config] is available if you want to see all the bells and whistles available.  Alternately, check out the [minimal configuration][offlineimap_minimal_config] needed to get working.  My example configuration is [here][my_offlineimap_config].

Assuming you are following my [suggested setup][], the configuration file goes under `~/.mail_configs/imapfilter`.

[offlineimap_full_example_config]:https://github.com/jgoerzen/offlineimap/blob/master/offlineimap.conf
[offlineimap_minimal_config]:https://github.com/jgoerzen/offlineimap/blob/master/offlineimap.conf.minimal
[my_offlineimap_config]:/files/example_email_configs/offlineimaprc.txt

[suggested setup]:#preparation

I suggest that you test it from the terminal to make sure that it's working at this point.  You will need to disable the hook to imapfilter if you haven't configured it yet.  Other sources of errors may be the port number, or if you're trying to connect to Gmail, be sure you have [enabled IMAP][] in the Gmail interface.

[enabled IMAP]:https://mail.google.com/support/bin/answer.py?answer=77695

{% highlight bash %}
offlineimap -c ~/.mail_configs/offlineimaprc
{% endhighlight %}

### Sorting mail with Imapfilter ###

[Imapfilter][] is another program which is able to sort and move messages around on the IMAP server.  I use it before calling offlineimap to sort my mail into the correct folder (ie, messages for a certain class into a given folder).  The configuration file can use [regular expressions][] to do the sorting, and is extendable using [Lua][], if you want to do so.

[regular expressions]:en.wikipedia.org/wiki/Regular_expression_examples
[Lua]:http://en.wikipedia.org/wiki/Lua_(programming_language)

Sorting can take place based on who an email is sent from, sent to, title contents, body contents, other header information, email size, age of the email, email status (recent, unread,...) and many other possibilities in combination.

[My example configuration][my_imapfilter_config] is actually quite simple.  You should really look at the [configuration manual][imapfilter_config_manual] and especially another [example][imapfilter_config_example] to see other things you can do with it.

[my_imapfilter_config]:/files/example_email_configs/imapfilter_example.lua.txt
[imapfilter_config_manual]:http://imapfilter.hellug.gr/imapfilter_config.5.txt
[imapfilter_config_example]:http://imapfilter.hellug.gr/sample.config.lua.txt

If you are following my [suggested setup][], put the configuration file under the `~/.mail_configs/imapfilter/` directory, with a `.lua` extension.

You can test your configuration using the following command.

{% highlight bash %}
imapfilter -vc ~/.mail_configs/imapfilter/file_name.lua
{% endhighlight %}

### Reading mail with Mutt ###

Now that you hopefully have your email synchronized to your machine, it's time to set up [mutt][] to read it.  This is the most configuration intensive portion of this how-to, but fortunately we can split up mutt's configuration file in a sensible and modular way for simplicity.

Before I throw down my own configuration files, I will point you to a page with a list of several different [mutt configuration examples][].  They have varying levels of documentation in them, and try to do different things.  This is, again, because mutt is _so darn configurable_ that it really can do just about anything you want to do.  As I mentioned previously, most of these setups let mutt handle everything regarding connecting to IMAP servers, sorting, connecting to SMTP servers to send and some other things.  It's a good place to look for ideas.

[mutt configuration examples]:http://wiki.mutt.org/?ConfigList

Moving on to my own configuration: assuming that you are still following my [suggested setup][], your mutt configuration files go under `~/.mail_configs/mutt/` directory.  The configuration files are split up as follows:

+ [muttrc][]: This is the main configuration file.  All the other configuration files are included from this file.
+ [common][]: Some global settings that I want to apply to every email account I read.
+ [colors][]: What the colors you want to be used in the display are.  This works well for me with a dark terminal.
+ [pgp][]: If you do use use [pgp][pgp_encryption] or [gpg][] encryption or signing email (or want to do so, all the cool kids are doing it :P), then this is the configuration file for doing that.  If you have no idea or interest in this, then ignore this file and remove the corresponding source statement from the muttrc file.
+ [school][school_mutt_conf] and [gmail][gmail_mutt_conf]: These are configuration files that are specific to the these specific email accounts, such as account specific signatures and such.  See the folder hooks in [muttrc][] used to load these based on what folder mutt is looking at.  Also, notice that these are very simple configuration files.  It is trivial to add more if you have more email accounts.

[muttrc]:/files/example_email_configs/mutt/muttrc.txt
[common]:/files/example_email_configs/mutt/common.txt
[colors]:/files/example_email_configs/mutt/colors.txt
[pgp]:/files/example_email_configs/mutt/pgp.txt
[school_mutt_conf]:/files/example_email_configs/mutt/school.txt
[gmail_mutt_conf]:/files/example_email_configs/mutt/gmail.txt

[pgp_encryption]:http://en.wikipedia.org/wiki/Pretty_Good_Privacy
[gpg]:http://en.wikipedia.org/wiki/GNU_Privacy_Guard


### Sending mail with Msmtp ###

[Msmtp][] is a very simple [SMTP][] client.  It contacts the SMTP server with your account credentials when you send mail, and then passes the sent email to the server.

[smtp]:http://en.wikipedia.org/wiki/Simple_Mail_Transfer_Protocol

To use it, first set up your configuration file.  My example configuration file is [here][my_msmtp_configuration], but you can also look at [another simple example][msmtp_simple_example].

[my_msmtp_configuration]:/files/example_email_configs/msmtprc.txt
[msmtp_simple_example]:http://msmtp.sourceforge.net/doc/msmtprc.txt

Assuming you are following my [suggested setup][], the file would be placed under `~/.mail_configs/msmtprc`.

Once you have your file set up, you can test it from the terminal to make sure it's working.  Assuming that it is working, you should see information about the SMTP server and the encryption certificate flash by, otherwise, there is an error.  In particular, if a self-signed certificate is being used, or a certificate from an uncommon signing authority, you may need to ignore the certificate check as shown in my configuration file.  Also, check to see what ports are being used by the server in question.

{% highlight bash %}
# Replace ACCOUNT_NAME with your account.
# In my example, this would be either 'school' or 'gmail'.
msmtp -C ~/.mail_configs/msmtp -Sa ACCOUNT_NAME
{% endhighlight %}

### Saving old emails with Archivemail ###

Here is an example that will take all mail from before January 1st, 2011 within the directory or file `cpts111`, and put it into a [gzipped][gzip] [mbox][] file `cpts111_records_fall_2010.gz`.

[gzip]:http://en.wikipedia.org/wiki/Gzip
[mbox]:http://en.wikipedia.org/wiki/Mbox

{% highlight bash %}
archivemail -D 2011-1-1 -uv --archive-name cpts111_records_fall_2010 cpts111
{% endhighlight %}

I can also iterate over all the directories correspoding to each class that I have set up.  A separate archive for each directory will be created.  My inboxes relating to classes are labeled starting with their with either 'ee' or 'cpts'.

{% highlight bash %}
ls | egrep ^(cpts|ee) | xargs archivemail -D 2011-1-1 -uvs _records_fall2010
{% endhighlight %}

It is also possible to set up archivemail to run from a cron job and keep a running archive, keeping your inbox clean of files older than a certain number of days, but as I don't use this personally, I leave the explanation to others.  Check out the man page for archive mail or Google to read many good examples online.

{::comment}
### Changelog ###

+ {{ page.date | date:"%b %d, %Y" }}: Initial post.
{:/comment}

