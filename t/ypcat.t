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

use Net::NIS;

$loaded = 1;

foreach my $map (@maps) {
  my %tied;
  tie %tied, 'Net::NIS', $map;
  ok $yperr, "", "tie '$map'";
  next if $yperr;

  # See what "ypcat -k" has to say... and let's hope none of its keys
  # have spaces in them.
  my %cmdline;
  open CMDLINE, "ypcat -k $map |"
    or die "open ypcat $map: $!\n";
  while (<CMDLINE>) {
    chomp;
    /^\s*$/ and next;		# skip blank lines

    # Allow leading whitespace, for the FreeBSD ypcat implementation
    /^\s*(\S+)\s+(.*)/
      or die "$map: cannot grok '$_'\n";
    $cmdline{$1} = $2;
  }
  close CMDLINE
    or die "close ypcat $map: $!\n";

  # Step 1: see what our package found, and make sure each of those was
  #         also listed by ypcat.  This is not likely to fail.
  my %tied_copy;
  foreach my $k (keys %tied) {
    exists $cmdline{$k}
      or die "$map: $k: in tied, not in cmdline\n";
    $tied_copy{$k} = $tied{$k};
    $cmdline{$k} eq $tied{$k}
      or die "$map: $k: tied = '$tied{$k}', cmdline = '$cmdline{$k}'\n";
  }

  # Step 2: see what ypcat found, and make sure each of those was also
  #         found by our package.  Note that %tied_copy is used as extra
  #         confirmation, because we happen to know that the "keys"
  #         iterator uses yp_all() to slurp in a copy of the entire
  #         map.  Thus %tied now returns theyp_all cached value,
  #         and %tied_copy preserves the results of yp_match done above.
  foreach my $k (keys %cmdline) {
    exists $tied{$k}
      or die "$map: $k: in cmdline, not in tied\n";
    exists $tied_copy{$k}
      or die "$map: $k: in cmdline, but not seen in yp_all()\n";

    $cmdline{$k} eq $tied{$k}
      or die "$map: $k: tied = '$tied{$k}', cmdline = '$cmdline{$k}'\n";
    $cmdline{$k} eq $tied{$k}
      or die "$map: $k: tied_copy = '$tied_copy{$k}', cmdline = '$cmdline{$k}'\n";
  }

  ok 1, 1, "foo";
}
