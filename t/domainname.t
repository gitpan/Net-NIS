# -*- perl -*-
#
# Our yp_get_default_domain() call must return the same as "domainname"
#
# NOTE: This uses an unpublished interface to Net::NIS
#
use strict;
use Test;

my $loaded = 0;

BEGIN {
  plan tests => 1;
}
END { $loaded or print "not ok 1\n"; }

use Net::NIS;

$loaded = 1;

chomp(my $domainname = `domainname`);

ok Net::NIS::yp_get_default_domain(), $domainname, 'domainname';
