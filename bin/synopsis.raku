#!/usr/bin/env perl6

use lib '../lib';

use Net::Google::Sheets;

my $session = Session.new;

my %sheets = $session.sheets;
my $id = %sheets<AWS_EC2_Sizes>;

# get values from Sheet1
my $sheet1 = Sheet.new(:$session, :$id, range => 'Sheet1');
my $vals = $sheet1.values;
say $vals;
#say $vals[1;*];

# put values into Sheet2
my $sheet2 = Sheet.new(:$session, :$id, range => 'Sheet2');
$sheet2.values: $vals;


