[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

# Net::Google::Sheets

Simple API access to Google Sheets, using [OAuth2::Client::Google](https://github.com/bduggan/p6-oauth2-client-google)

## Install
```raku
zef install Net::Google::Sheets 
```

Follow the [HOW-TO](https://raku.land/cpan:BDUGGAN/OAuth2::Client::Google#quick-how-to) to make a client_id.json in your script
dir (eg. /bin for /bin/synopsis)

## Synopsis 
```raku
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
```

### Copyright
copyright(c) 2023-2024 Henley Cloud Consulting Ltd.
