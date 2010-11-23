---
layout: post
title: kramdown support for Jekyll
tags: [kramdown, blog, jekyll, code]
time: '10:24'
updated: '2010-11-23'
---

**Update {{ page.updated | date:"%b %d, %Y" }}**: My changes have been merged into the mainline branch, which can be found on [Github][Jekyll].
{: .update}

The last several months I've been fiddling around with different [Markdown][] converters used with [Jekyll][Jekyll readme].  I like [Maruku's][maruku] enhanced feature set (footnotes are nice), but was dissapointed with the execution speed.  I briefly played around with [Rdiscount][], which is *much* faster, but didn't ended up missing the extra features of Maruku.

[Markdown]:http://daringfireball.net/projects/markdown/
[Jekyll]:https://github.com/mojombo/jekyll
[Jekyll readme]:https://github.com/mojombo/jekyll#readme
[maruku]:http://maruku.rubyforge.org/maruku.html
[Rdiscount]:https://github.com/rtomayko/rdiscount#readme

I then discovered [kramdown][].  It seems like a happy middle between Maruku and Rdiscount [performance-wise][performance], while containing a feature set even larger than that of Maruku.  Unfortunately, it isn't yet supported by Jekyll, though it had been a [long requested][] feature.

[kramdown]:http://kramdown.rubyforge.org/
[performance]:http://kramdown.rubyforge.org/tests.html
[long requested]:https://github.com/mojombo/jekyll/issuesearch?state=open&q=kramdown#issue/175

I waited for a couple months, and then decided to [fork][] Jekyll and add the functionality myself.  At the time, I was unsure how to support [options][] passed to kramdown's HTML parser, so I left that part off to work on later.

[fork]:https://github.com/jasongraham/jekyll
[options]:http://kramdown.rubyforge.org/converter/html.html#options

Another coder apparently had the same idea as me at almost exactly the same time, and created [his own fork] with the same functionality, but also didn't add the options passing.

[his own fork]:https://github.com/digitalsanctum/jekyll/tree/add_kramdown_support

With the start of Thanksgiving break, I've finally had some time to tack on the options functionality.  It goes into the [site configuration YAML file][config] just like Maruku options or Rdiscount extensions would.

[config]:https://github.com/jasongraham/jekyll/wiki/Configuration

Hopefully, the fork will be pulled into the main branch, though I may need to clean up the options passing portion, it admittedly feels a bit hackish.  I'm a n00b ruby coder, so my excuse is that I don't know any better.  Fixes or suggestions are welcome though.

You can find the fork on [Github][fork], or my own [personal repository][] on this site.

[personal repository]:http://code.the-graham.com/jekyll
