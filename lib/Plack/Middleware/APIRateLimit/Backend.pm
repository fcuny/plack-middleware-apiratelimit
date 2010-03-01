package Plack::Middleware::APIRateLimit::Backend;

use Moose;
use Carp;

sub incr {
    confess "Backend must implement an incr method";
}

sub get {
    confess "Backend must implement a get method";
}

1;
