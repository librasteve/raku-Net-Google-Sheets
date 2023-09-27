#!/usr/bin/env perl6

use lib '../lib';
use Net::Google::Sheets;


my $session = Session.new;

my %sheets = $session.sheets;
my $id = %sheets<AWS_EC2_Sizes>;

my $range = 'Sheet1';
my $sheet = Sheet.new(:$session, :$id, :$range);

say $sheet.values[1;*];
