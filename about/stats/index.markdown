---
layout: default
title: Realtime Statistics
---

## Realtime Server Statistics ##

<img class="img_right" src="http://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/SheevaPlug_with_external_drive_enclosure.jpg/300px-SheevaPlug_with_external_drive_enclosure.jpg" />

This is a page that, in theory, should show the real-time statistics of the server for the past 24 hours.  The site is run by a [Sheevaplug][] plug computer.

This server is running:

* The the-graham.com website, including:
	* This [blog][].
	* A small [code repository][].
* A wordpress based [family oriented blog][].
* Rsync based file backups for my other computers.
* A few assorted other services.

[family oriented blog]:http://www.graham-clan.net

Scripts to log and graph the activities are mostly unmodified versions of those written by Kenny at [computingplugs.com][], a [mediawiki][] setup that is itself run by a Sheevaplug.  The update scripts run every minute, and the graphs are updated every ten minutes.  They do disappear after I write a post, but they reappear in at most 10 minutes when the graphs update.

### Uptime ###
<img class="full_width" src="/images/uptime.gif">

### Server Load ###
<img class="full_width" src="/images/load.png">

### CPU ###
<img class="full_width" src="/images/cpu.png">

### Memory ###
<img class="full_width" src="/images/memory.png">

### Network ###
<img class="full_width" src="/images/net.png">

### Disk Usage ###
<img class="full_width" src="/images/sda.png">

[SheevaPlug]:http://en.wikipedia.org/wiki/SheevaPlug
[blog]:/
[code repository]:http://code.the-graham.com
[computingplugs.com]:http://computingplugs.com
[mediawiki]:http://www.mediawiki.org/
