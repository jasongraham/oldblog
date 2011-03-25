#!/usr/bin/perl -w
#
## Calomel.org -- strip_whitespace.pl
#
## PURPOSE: This program will strip out all
##    whitespace from a HTML file except what is
##    between the pre and /pre and tags.
#
## DEPENDANCIES: p5-HTML-Parser which you can get by CPAN or
##    installing a package from your OS supporters.
#
## USAGE: ./strip_whitespace.pl < input.html > output.html
#

use HTML::Parser;
my $preserve = 0;

# Ignore any test between the /pre tags
sub process_tag
{
    my ($tag, $text) = @_;
    if ($tag eq 'pre') { $preserve = 1; }
    elsif ($tag eq '/pre') { $preserve = 0; }
    print $text;
}

# Replace all white space with a single space except what
# is between the pre tags. This includes all tabs (\t),
# returns (\r) and new line characters (\n).
sub process_default
{
    my ($text) = @_;
    $text =~ s/\s+/ /g unless $preserve;
    print $text;
}

undef $/;
$_ = <STDIN>;

my $p = HTML::Parser->new(
    start_h => [\&process_tag, 'tag,text'],
    end_h => [\&process_tag, 'tag,text'],
    default_h => [\&process_default, 'text']
);

$p->parse($_);

## EOL

