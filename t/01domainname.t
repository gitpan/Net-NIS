# -*- perl -*-
#
# Our yp_get_default_domain() call must return the same as "domainname"
#
# NOTE: This uses an unpublished interface to Net::NIS
#
use strict;
use Test::More tests => 1;

use Net::NIS;

# See what the 'domainname' command returns.  Note that some
# versions return '(none)' (left-paren, none, right-paren).
chomp(my $domainname_per_cmdline = `domainname`);
if ($domainname_per_cmdline eq '(none)') {
    $domainname_per_cmdline = '';
}

# Now see what our library returns.
my $domainname_per_Net_NIS = Net::NIS::yp_get_default_domain() || '';

is $domainname_per_Net_NIS, $domainname_per_cmdline, 'domainname';
