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

# compress jpegs
find _site -type f | egrep "*.jpg" | while read file
do
    jpegtran -copy none -optimize -progressive -outfile $file.crushed $file
    find _site -name "*.crushed" -print | sed "s/\\(.*\\)\\.jpg.crushed/ & \\1.jpg/" | xargs -L1 mv
done


# compress pngs
find _site -name "*.png" -print | xargs -L1 pngcrush -q -e .crushed -rem time -rem alla -rem allb -l 9 -w 32 -plte_len 0 -reduce -rem gAMA -rem cHRM -rem iCCP -rem sRGB -brute
find _site -name "*.crushed" -print | sed "s/\\(.*\\)\\.crushed/ & \\1.png/" | xargs -L1 mv
