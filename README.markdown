---

## About ##

This represents the source code making up my blog,
[jason.the-graham.com][blog].  It is found in my [personal source code
repository][my repo], and is mirrored on [Github][mirror].

[blog]:http://jason.the-graham.com
[my repo]:http://code.the-graham.com/blog
[mirror]:https://github.com/jasongraham/blog

The site is generated through [Jekyll][], using [kramdown][] as a
[Markdown][] interpreter.  Originally, I was using my own forked version
with kramdown functionality added, but kramdown functionality was merged
into Jekyll as of version 0.8.

[Jekyll]:https://github.com/mojombo/jekyll
[kramdown]:http://kramdown.rubyforge.org/
[Markdown]:http://daringfireball.net/projects/markdown/

Rather than explicitly calling Jekyll, I use `rake` to compile the site.  See
the included Rakefile.

## License ##

The contents of the following files directories are the copyright of Jason
Graham.  You may not use them without permission.

+ `about/`
+ `images/`, with the exception of `images/icons`, which are the
  work of [komodomedia.com][].

[komodomedia.com]:http://www.komodomedia.com/blog/2009/06/social-network-icon-pack/

The following content is available through the [Creative Commons
Attribution-Noncommercial-No Derivative Works License][by-nc-nd].

[by-nc-nd]:http://creativecommons.org/licenses/by-nc-nd/3.0/

+ `_posts/`

Any other content is [MIT][] licensed unless explicitly stated.  If
you find them useful, credit would be nice, but is not required.

[MIT]:https://secure.wikimedia.org/wikipedia/en/wiki/MIT_License
