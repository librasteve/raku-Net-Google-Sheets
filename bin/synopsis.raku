#!/usr/bin/env raku
use Net::Google::Sheets;

my $session = Session.new;

my %sheets = $session.sheets;
my $id = %sheets<AWS_EC2_Sizes_test>;

# get values from Sheet1
my $sheet1 = Sheet.new(:$session, :$id, range => 'Sheet1');
my $vals = $sheet1.values;
dd $vals;

my @vals = $sheet1.values;
dd @vals;

# put values into Sheet2
my $sheet2 = Sheet.new(:$session, :$id, range => 'Sheet2');
$sheet2.values: $vals;

# clear Sheet2
$sheet2.clear;


