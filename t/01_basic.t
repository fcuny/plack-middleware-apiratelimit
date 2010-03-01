use strict;
use warnings;
use Test::More;

use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;

#use AnyEvent::Redis;
#my $redis = AnyEvent::Redis->new(port => 6379, server => '127.0.0.1');
#$redis->flushall;

my $handler = builder {
    enable "APIRateLimit";
    #enable "APIRateLimit", requests_per_hour => 2, backend => "Hash";
    #enable "APIRateLimit",
        #requests_per_hour => 2,
        #backend => [ "Redis", { port => 6379, server => '127.0.0.1' } ];
    sub { [ '200', [ 'Content-Type' => 'text/html' ], ['hello world'] ] };
};

test_psgi
    app    => $handler,
    client => sub {
    my $cb = shift;
    use YAML::Syck;
    {
        for ( 1 .. 2 ) {
            my $req = GET "http://localhost/";
            my $res = $cb->($req);
            is $res->code, 200;
	    ok $res->headers('X-RateLimit-Limit');
#	    warn Dump $res;
        }
        my $req = GET "http://localhost/";
        my $res = $cb->($req);
        is $res->code, 503;
	ok $res->headers('X-RateLimit-Reset');
#	warn Dump $res;
    }
};

done_testing;
