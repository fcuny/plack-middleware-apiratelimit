package Plack::Middleware::APIRateLimit::Backend::Redis;

use Moose;
extends 'Plack::Middleware::APIRateLimit::Backend';

use Redis;

has store => (
    is      => 'rw',
    isa     => 'Redis',
    lazy    => 1,
    default => sub {
        return Redis->new(
            server => '127.0.0.1:6379'
        );
    }
);

sub BUILD {
    my ( $self, $opt ) = @_;
    if ($opt) {
        $self->store( Redis->new(%$opt) );
    }
    return $self;
}

sub get {
    my ( $self, $key ) = @_;
    $self->store->get($key);
}

sub set {
    my ($self, $key, $value) = @_;
    $self->store->set($key, $value);
}

sub incr {
    my ( $self, $key ) = @_;
    $self->store->incr($key);
}

1;
