#!/bin/bash

# Run HTML White space remover
echo "Minifying HTML..."
for f in `find _site/ -name \*.html | egrep -v '^_site/google'`; do
    mv $f $(echo "$f" | sed 's/html$/html.old/')
    _lib/strip_whitespace.pl < $f.old > $f
    rm $f.old
done

# gzip all files larger than 500B as much as possible
find _site -type f -size +500c | egrep -v "*.(jpg|gif|png|pdf|zip|gz|woff)$" | while read file
do
    gzip --best -n <$file >$file.gz
done

