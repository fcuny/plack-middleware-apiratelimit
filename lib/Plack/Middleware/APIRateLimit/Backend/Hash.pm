package Plack::Middleware::APIRateLimit::Backend::Hash;

use Moose;
extends 'Plack::Middleware::APIRateLimit::Backend';

has store => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => ['Hash'],
    lazy    => 1,
    default => sub { {} },
    handles => { get => 'get', set => 'set' }
);

sub incr {
    my ( $self, $key ) = @_;
    my $value = ($self->get($key) || 0) + 1;
    $self->set( $key => $value );
}

1;
