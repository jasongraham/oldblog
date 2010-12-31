#!/usr/bin/perl

# cssOptimizer.pl
# version 1.0
# usage: ./cssOptimizer.pl input.css output.css

# Copyright 2010 Cyril Pierron

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# https://p6ril.wordpress.com/2010/06/30/minify-your-css-files-speed-and-other-seo-wizardry/

use strict;
use warnings;

sub remInlComments {
	my $str = shift;
	my $i = index $str, '/*';
	my $j = 0;
	while ($i >= 0 && ($j = index $str, '*/', $i + 2) > 0) {
		substr $str, $i, $j - $i + 2, '';
		$i = index $str, '/*';
	}
	return $str;
}

sub rgbOptim {
	my @rgb = split(/,/, shift);
	my $hexCode = '#';
	foreach (@rgb) {
		if ($_ < 16) {
			$hexCode .= '0'.sprintf("%x", $_);
		}
		else {
			$hexCode .= sprintf("%x", $_);
		}
	}
	$hexCode =~ s/([a-f]|\d)\1([a-f]|\d)\2([a-f]|\d)\3/$1$2$3/; # shortens the color hexa code when relevant, 'rrggbb' becomes 'rgb'
	return $hexCode;
}

if (@ARGV < 2) {
	print "\ncssOptimizer v1.0 - Copyright 2010 Cyril Pierron\n\n";
	print "cssOptimizer is a Perl script that expects 2 arguments on the command line:\n";
	print "\t1. the path and name of the CSS file to minify and\n";
	print "\t2. the path and name of the resulting CSS file.\n\n";
	print "usage: ./cssOptimizer.pl input.css output.css\n\n";
	print "Remember to give cssOptimizer.pl the execution rights in a UNIX like environment.\n\n";
	exit;
}

my $input = $ARGV[0];
my $output = $ARGV[1];

open(my $in, '<', $input) or die "Can't open ".$input.": $!";
my $optimizedCSS = '';
my $comment = 0; # used as a boolean to detect multi-lines comments /* ... */
my $counter = 0; # increments with each line of the input css file, can be useful for debugging purposes
while (<$in>) { # assigns each line in turn to $_
	$counter += 1;
	if ($comment && /\*\//) { # the end of a multi-lines comment is found
		substr $_, 0, index($_, '*/') + 2, ''; # removes the comment part from the begining of the line, keeping the end of the line (if any) - it may still contain css rules or other comments
		$comment = 0; # we're not inside a multi-lines comment anymore
	}
	$_ = remInlComments($_) if (!$comment); # removes any number of properly opened and closed inline comments
	$comment = 1 if (!$comment && /^\s*\/\*/); # if the line begins with /* a multi-lines comment starts and should be ignored
	if (!/^$/ && !$comment) { # empty lines and comments do not need any processing, these lines are ignored
		s/^\s+//; # strips any number of whitespace characters (space, tab, newline, ...) at the begining of a line
		s/\s*(,|:|;|\(|\{|\}|\>)\s*/$1/g; # trims any number of whitespace characters around comma, column, semi-column, opening braces, curly-braces and greater than signs
		s/\s+\)/)/g; # specific case of the closing brace that can be followed with a space (shorthand property values case for instance)
		s/(\D)(0)(px|em|ex|%)/$1$2/g; # when value is 0 unit is unnecessary
		s/0\.(\d)/\.$1/g; # lower than 1 values do not require to be preceded by 0
		my $rgbCode = rgbOptim($1) if (/rgb\((\d{1,3},\d{1,3},\d{1,3})\)/);
		s/rgb\(\d{1,3},\d{1,3},\d{1,3}\)/$rgbCode/g;
		s/(\s+)$//; # removes any number of tailing whitespace characters
		s/\s+/ /g; # replaces any number of remaining consecutive whitespace characters with just one space
		if(/\/\*/) { # a multi-lines comment starts somwhere within the current line
			s/\s*\/\*.*//; # removes the comment part from the end of the line
			$comment = 1; # from now on we're inside a multi-lines comment
		}
		$optimizedCSS .= $_;
	}
}
close $in or die "$in: $!";
# $optimizedCSS is now one big long line containing the whole css document, any regex applies globaly
$optimizedCSS =~ s/;\}/\}/g; # removes unnecessary semi-column before closing curly braces
open(my $out, '>', $output) or die "Can't open ".$output.": $!";
print $out $optimizedCSS;
close $out or die "$out: $!";
my $iSize = -s $input;
my $oSize = -s $output;
print "CSS optimization result:\n";
print 'before: '.$iSize." bytes\n";
print 'after: '.$oSize." bytes\n";
print sprintf("compression ratio: %1.1f",(1-($oSize/$iSize))*100)."%\n\n";
