#!/usr/bin/env perl6

use lib '../lib';

use OAuth2::Client::Google;
use JSON::Fast;
use HTTP::UserAgent;
use URI::Encode;

#viz. https://developers.google.com/drive
#viz. https://developers.google.com/sheets

my $debug = 0;

constant $drive-base = 'https://www.googleapis.com/drive/v3/files';
constant $sheet-base = 'https://sheets.googleapis.com/v4/spreadsheets';

constant $creds-file = 'client_id.json';
constant $token-file = 'token.txt';

sub q-enc($q ) {
    uri_encode_component($q);
}

sub reload-token {

    # we need a web browser to receive the request.
    my $browser = %*ENV<BROWSER> || qx{which xdg-open} || qx{which x-www-browser} || qx{which open};
    $browser .= chomp;

    # use a localhost URL from the config file.
    my $type = 'web'; # or it could be 'installed' depending on your credentials

    $creds-file.IO.e or die "No $creds-file";
    my $config = $creds-file.IO.slurp.&from-json;

    my $uri = $config{$type}<redirect_uris>.first({ /localhost/ }) or
      die "no localhost in redirect_uris: add one and update $creds-file";

    $uri ~~ / 'http://localhost:' $<port>=[(<[0..9]>+)]? $<path>=('/' \N+)? $ / or die "couldn't parse $uri";
    my $port = $<port> // 80;
    my $path = $<path> // '/';
    say "using $uri from config file";

    # set up Oauth request
    my $oauth = OAuth2::Client::Google.new(
        type => 'web',
        config => $config,
        redirect-uri => $uri,
        scope => "https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/spreadsheets",
    );
    my $auth-uri = $oauth.auth-uri;

    # start browser
    say "starting web server at localhost:$port";
    say "opening browser to $auth-uri";
    my $proc = run($browser,$auth-uri);

    # then start server
    my $response = q:to/HERE/.encode("UTF-8");
    HTTP/1.1 200 OK
    Content-Length: 7
    Connection: close
    Content-Type:text/plain

    all set!
    HERE

    my $in;
    my $done;
    my $sock = IO::Socket::Async.listen('localhost', $port);

    # and wait for code
    $sock.tap( -> $connection {
        $connection.Supply.tap( -> $str {
            $in ~= $str;
            if $str ~~ /\r\n\r\n/ {
                $connection.write($response);
                $connection.close;
                $done = True;
            }
          });
    });
    loop { last if $done; };

    $in ~~ / 'GET' .* 'code=' $<code>=(<-[&]>+) /;
    my $code = $<code> or die "did not get code in query params";
    say "Got code $code";

    # convert code to a token
    my $access = $oauth.code-to-token(:$code);
    my $token  = $access<access_token> or die "could not get access token : { $access.gist } ";
    $token-file.IO.spurt: $token;
    say "Got access token $token";

    $token;
}

my $ua = HTTP::UserAgent.new;
my $query;

# persist token in local file
my $token = $token-file.IO.slurp or warn 'no token file, loading oauth permissions';

# check token is valid
$query = q|mimeType != 'application/vnd.google-apps.folder' and 'root' in parents|;

my $got-check = $ua.get(
    "$drive-base?q={q-enc($query)}",
    Authorization => "Bearer $token",
);

if $got-check.decoded-content.&from-json<error> || $debug {
    $token = reload-token();
}

$query = q|mimeType = 'application/vnd.google-apps.spreadsheet' and 'root' in parents|;

my $got-drive = $ua.get(
    "$drive-base?q={q-enc($query)}",
    Authorization => "Bearer $token",
);

my %sheets = $got-drive.decoded-content.&from-json<files>.map: {$^file<name> => $^file<id>};

my $spreadsheet_id = %sheets<AWS_EC2_Sizes>;
my $range = 'Sheet1';

my $got-sheet = $ua.get(
    "$sheet-base/$spreadsheet_id/values/$range",
    Authorization => "Bearer $token"
);

say $got-sheet.decoded-content.&from-json<values>[1;*];


