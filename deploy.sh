#!/bin/bash

script="./deploy.sh"

# make sure we are in the jekyll root directory
# (where deploy.sh should be)
if [ -f $script ] ; then 
	echo "Compiling site..."
else
	echo "Please run this script from the jekyll site's root directory. Exiting..."
	exit 1
fi

# start the site over from scratch
rm -rf _site/* && \

# Generate the cloud to include before running jekyll
./_scripts/generate_cloud.py 40 10 . > ./_includes/cloud.html && \

# fetch current gravatar image and use for favicon
./_scripts/gen_favicon.sh

# Run the jekyll and then
# rsync the _site directory with the server
jekyll --lsi

for f in _site/css/*.css; do
    echo "Minifying $f..."
    mv $f $f.old
    ./_scripts/cssOptimizer.pl $f.old $f
    rm $f.old
done

find _site -type f -size +500c | egrep -v "*.(jpg|gif|png|pdf|zip|gz|woff)$" | while read file
do 
    gzip --best <$file >$file.gz
done

rsync -avz --delete _site/ homeserver:blog/

# explicitly ping google only when 'ping' is passed as a parameter to the script
# ie, ./deploy ping

if [ $# -gt 0 ] ; then
if [ $1 = ping ] ; then
	echo "Pinging Update Services..."

	# Ping google tell them the sitemap has been updated
	wget --output-document=/dev/null http://www.google.com/webmasters/tools/ping?sitemap=http%3A%2F%2Fjason.the-graham.com%2Fsitemap.xml

	# and bing
	wget --output-document=/dev/null http://www.bing.com/webmaster/ping.aspx?siteMap=http://jason.the-graham.com/sitemap.xml

	# and blog search engines
	./_scripts/rpcping.pl "Blog for Jason Graham" http://jason.the-graham.com/
else
	echo "Use \"$0 ping\" to ping google about an update."
fi
fi
