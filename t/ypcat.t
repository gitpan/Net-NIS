# -*- perl -*-
#
# compare our results against what "ypcat -k <map>" finds
#
use Test;

my $loaded = 0;

use strict;
use vars qw(@maps);

BEGIN {
  @maps = qw(passwd.byname
	     passwd.byuid
	     group.byname
	     hosts.byname
	     mail.aliases);
  plan tests => 2 * @maps;
}

END   { $loaded or print "not ok 1\n" }

use Net::NIS qw($yperr YPERR_DOMAIN YPERR_NODOM YPERR_MAP);

$loaded = 1;

foreach my $map (@maps) {
    my $ok = 1;

    my %tied;
    tie %tied, 'Net::NIS', $map;
    # Build machine could be YP-less.  We should still allow tests to pass.
    if (grep { $yperr == $_ } (YPERR_DOMAIN, YPERR_NODOM, YPERR_MAP)) {
	skip "skip: $yperr", "", "";
	skip "skip: $yperr", "", "";
	next;
    }
    ok $yperr, "", "tie '$map'";
    next if $yperr;

    # See what "ypcat -k" has to say.  Remember each key/value pair seen.
    #
    # We can't keep them in a hash, because some bozo sysadmins have
    # maps whose keys have spaces in them.  In parsing the output of
    # ypcat, we cannot detect those.
    my @cmdline;
    open CMDLINE, "ypcat -k $map |"
      or die "open ypcat $map: $!\n";
    while (<CMDLINE>) {
	chomp;
	/^\s*$/ and next;		# skip blank lines

	# Allow leading whitespace, for the FreeBSD ypcat implementation
	/^\s*(\S+)\s+(.*)/
	  or die "$map: cannot grok '$_'\n";
	push @cmdline, "$1 $2";
    }
    close CMDLINE
      or die "close ypcat $map: $!\n";

    # Step 1: see what our package found, and make sure each of those was
    #         also listed by ypcat.  This is not likely to fail.
    while (my ($key, $val) = each %tied) {
	my $pair = "$key $val";
	my @cmdline_match = grep { $pair eq $cmdline[$_] } (0..$#cmdline);

	if (@cmdline_match == 0) {
	    warn "Pair seen in \%tied, but not ypcat: '$pair'\n";
	    $ok = 0;
	}
	elsif (@cmdline_match > 1) {
	    warn "WEIRD!  Too many matches for '$pair'!\n";
	    $ok = 0;
	}
	else {
	    # Exactly one match, as expected.
	    #
	    # Forget about it, we shan't be seeing it again.
	    splice @cmdline, $cmdline_match[0], 1;
	}
    }

    # Step 2: Is there anything left of what ypcat found?  There shouldn't
    #         be, because we delete each ypcat key/value pair as soon as we
    #         find it in our own list.
    if (@cmdline) {
	warn "Some key/value pairs listed by ypcat, but not found by me:\n";
	warn "  : $_\n"		for @cmdline;
    }

    ok $ok, 1, "\$ok";
}
