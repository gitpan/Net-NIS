# -*- perl -*-
#
# test the Net::NIS::Table interface
#
use Test;

my $loaded = 0;

use strict;
use vars qw(@maps);

BEGIN {
  plan tests => 3;
}

END   { $loaded or print "not ok 1\n" }

use Net::NIS::Table;

$loaded = 1;

my $hosts = Net::NIS::Table->new("hosts.byname");

# Check that we got back _something_ valid
ok ref ($hosts), "Net::NIS::Table", "ref(\$hosts)";

# Can we get a list of hosts?
my $data;
eval '$data = $hosts->list()';
ok $@, '', 'eval { $hosts->list }';
ok ref ($data), 'HASH', '$hosts->list did not return a hash';
