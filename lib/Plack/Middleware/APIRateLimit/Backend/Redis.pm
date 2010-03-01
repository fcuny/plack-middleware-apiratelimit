package Plack::Middleware::APIRateLimit::Backend::Redis;

use Moose;
extends 'Plack::Middleware::APIRateLimit::Backend';

use AnyEvent::Redis;

has store => (
    is      => 'rw',
    isa     => 'AnyEvent::Redis',
    lazy    => 1,
    default => sub {
        return AnyEvent::Redis->new(
            host => '127.0.0.1',
            port => 6378,
        );
    }
);

sub BUILD {
    my $self = shift;
    if (scalar @_) {
        $self->store(AnyEvent::Redis->new(@_));
    }
    return $self;
}

sub get {
    my ( $self, $key ) = @_;
    my $val = $self->store->get($key)->recv;
    if ( !$val ) {
        $self->store->set( $key => 1 )->recv;
        $val = 1;
    }
    return $val;
}

sub incr {
    my ($self, $key) = @_;
    return $self->store->incr($key)->recv;
}

1;
