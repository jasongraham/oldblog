#!/usr/bin/perl
#
# rpcping.pl - Ping your blog with update services
#
# © Copyright, 2006 by John Bokma, http://johnbokma.com/
# License: The Artistic License
#
# $Id: rpcping.pl 1083 2008-09-30 19:06:18Z john $ 
#
# Modified: Jason Graham http://jason.the-graham.com
# May 29, 2010

use strict;
use warnings;

use XMLRPC::Lite;

sub print_usage_and_exit {

	print <<USAGE;
usage: rpcping.pl "YOUR WEBLOG NAME" URL
USAGE

        exit;

}

@ARGV == 2 or print_usage_and_exit;
my ( $blog_name, $blog_url ) = @ARGV;

my @services = (

		# See http://codex.wordpress.org/Update_Services for
		# a more comprehensive list.
		'Google'         => 'http://blogsearch.google.com/ping/RPC2',
		'Weblogs.com'    => 'http://rpc.weblogs.com/RPC2',
		'Feed Burner'    => 'http://ping.feedburner.com/',
		'Ping-o-Matic!'  => 'http://rpc.pingomatic.com/',
	       );

while ( my ( $service_name, $rpc_endpoint ) = splice @services, 0, 2 ) {

	my $xmlrpc = XMLRPC::Lite->proxy( $rpc_endpoint );
	my $call;
	eval {
		$call = $xmlrpc->call( 'weblogUpdates.ping',
				$blog_name, $blog_url );
	};
	if ( $@ ) {

		chomp $@;
		warn "Ping '$service_name' failed: '$@'\n";
		next;
	}

	unless ( defined $call ) {

		warn "Ping '$service_name' failed for an unknown reason\n";
		next;
	}

	if ( $call->fault ) {

		chomp( my $message = $call->faultstring );
		warn "Ping '$service_name' failed: '$message'\n";
		next;
	}

	my $result = $call->result;
	if ( $result->{ flerror } ) {

		warn "Ping '$service_name' returned the following error: '",
		     $result->{ message }, "'\n";
		next;
	}

	print "Ping '$service_name' returned: '$result->{ message }'\n";
}
