#!/usr/bin/env perl

use 5.020;
use strict;
use warnings;
use utf8;
use FindBin qw< $Bin >;
use lib "$Bin/local/lib/perl5";
use lib "$Bin/lib";
use Lab::Labels::Web;
Lab::Labels::Web->run_if_script;
