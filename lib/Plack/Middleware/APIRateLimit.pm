package Plack::Middleware::APIRateLimit;

use strict;
use warnings;

use Carp;
use Scalar::Util;
use Plack::Util;
use DateTime;

our $VERSION = '0.01';

use parent 'Plack::Middleware';

use Plack::Util::Accessor qw(
    backend
    auth_key
    requests_per_hour
    requests_per_hour_auth
);

sub prepare_app {
    my $self = shift;
    $self->backend( $self->_create_backend( $self->backend ) );
}

sub _create_backend {
    my ( $self, $backend ) = @_;

    return $backend if defined $backend && Scalar::Util::blessed $backend;

    my ( $backend_name, $backend_options ) = ( undef, {} );

    if ( !defined $backend ) {
        $backend_name = "Hash";
    }
    elsif ( ref $backend eq 'ARRAY' ) {
        $backend_name    = shift @$backend;
        $backend_options = shift @$backend;
    }
    else {
        $backend_name = $backend;
    }

    Plack::Util::load_class(
        "Plack::Middleware::APIRateLimit::Backend::" . $backend_name )
        ->new($backend_options);
}

sub call {
    my ( $self, $env ) = @_;

    my $res = $self->app->($env);

    my $key = $self->_generate_key($env);

    $self->backend->incr($key);
    my $request_done = $self->backend->get($key);

    if (!$request_done) {
        $self->backend->set($key, 1);
        $request_done = 1;
    }

    return $self->over_rate_limit()
        if $request_done > $self->requests_per_hour;

    $self->response_cb(
        $res,
        sub {
            my $res     = shift;
            my $headers = $res->[1];
            Plack::Util::header_set( $headers, 'X-RateLimit-Limit',
                $self->requests_per_hour );
            Plack::Util::header_set( $headers, 'X-RateLimit-Remaining',
                ( $self->requests_per_hour - $request_done ) );
            Plack::Util::header_set( $headers, 'X-RateLimit-Reset',
                $self->_reset_time );
            return $res;
        }
    );
}

sub _generate_key {
    my ( $self, $env ) = @_;
    if ( $env->{REMOTE_USER} ) {
        return $env->{REMOTE_USER} . "_"
            . DateTime->now->strftime("%Y-%m-%d-%H");
    }
    else {
        return $env->{REMOTE_ADDR} . "_"
            . DateTime->now->strftime("%Y-%m-%d-%H");
    }
}

sub _reset_time {
    my $dt = DateTime->now;
    3600 - (( 60 * $dt->minute ) + $dt->second);
}

sub over_rate_limit {
    my ($self) = @_;
    return [
        503,
        [
            'Content-Type'      => 'text/plain',
            'X-RateLimit-Reset' => $self->_reset_time
        ],
        ['Over Rate Limit']
    ];
}

1;
__END__

=head1 NAME

Plack::Middleware::APIRateLimit - A Plack Middleware for API Throttling

=head1 SYNOPSIS

  my $handler = builder {
    enable "APIRateLimit";
    # or
    enable "APIRateLimit", requests_per_hour => 2, backend => "Hash";
    # or
    enable "APIRateLimit", requests_per_hour => 2, backend => ["Redis", {port => 6379, server => '127.0.0.1'}];
    # or
    enable "APIRateLimit", request_per_hour => 2, backend => Redis->new(server => '127.0.0.1:6379');

    sub { [ '200', [ 'Content-Type' => 'text/html' ], ['hello world'] ] };
  };

=head1 DESCRIPTION

Plack::Middleware::APIRateLimit is a Plack middleware for controlling API
access.

Set a limit on how many requests per hour is allowed on your API. In the case
of a authorized request, 3 headers are added:

=over 2

=item B<X-RateLimit-Limit>

How many requests are authorized by hours

=item B<X-RateLimit-Remaining>

How many remaining requests

=item B<X-RateLimit-Reset>

When will the counter be reseted (in epoch)

=back

=head2 VARIABLES

=over 4

=item B<backend>

Which backend to use. Currently only Hash and Redis are supported. If no
backend is specified, Hash is used by default. Backend must implement B<set>,
B<get> and B<incr>.

=item B<requests_per_hour>

How many requests is allowed by hour.

=back

=head1 AUTHOR

franck cuny E<lt>franck@linkfluence.netE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
