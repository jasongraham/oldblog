#!/bin/bash

script="./deploy.sh"

if [ -f $script ] ; then 
	echo "Compiling site..."
else
	echo "Please run this script from the jekyll site's root directory. Exiting..."
	exit 1
fi

# start the site over from scratch
rm -rf _site/* && \

# Generate the cloud to include before running jekyll
./_scripts/generate_cloud.py 50 10 . > ./_includes/cloud.html && \

# Run the jekyll and then
# rsync the _site directory with the server
jekyll --lsi && \
rsync -avz --delete _site/ homeserver:blog/

# Ping google tell them the sitemap has been updated
wget --output-document /dev/null http://www.google.com/webmasters/tools/ping?sitemap=http%3A%2F%2Fjason.the-graham.com%2Fsitemap.xml

# and bing
wget --output-document /dev/null http://www.bing.com/webmaster/ping.aspx?siteMap=http%3A%2F%2Fjason.the-graham.com%2Fsitemap.xml > /dev/null

# and feedburner
wget --output-document /dev/null http://feedburner.google.com/fb/a/pingSubmit?bloglink=http%3A%2F%2Fjason.the-graham.com > /dev/null
