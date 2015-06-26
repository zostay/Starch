#!/usr/bin/env perl
use strictures 2;

use Test::More;

use Web::Starch;

my $expires = 60 * 60 * 8;

my $starch = Web::Starch->new_with_plugins(
    ['::CookieArgs'],
    store => { class => '::Memory' },
    cookie_name      => 'foo-session',
    cookie_expires   => $expires,
    cookie_domain    => 'foo.example.com',
    cookie_path      => '/bar',
    cookie_secure    => 0,
    cookie_http_only => 0,
);

subtest cookie_args => sub{
    my $session = $starch->session();

    my $args = $session->cookie_args();
    is( $args->{name}, 'foo-session', 'cookie name is correct' );
    is( $args->{value}, $session->id(), 'cookie value is session ID' );
    is( $args->{expires}, $expires, 'cookie expires is correct' );
    is( $args->{domain}, 'foo.example.com', 'cookie domain is correct' );
    is( $args->{path}, '/bar', 'cookie path is correct' );
    is( $args->{secure}, 0, 'cookie secure is correct' );
    is( $args->{httponly}, 0, 'cookie httponly is correct' );

    $session->force_save();
    $session->expire();

    $args = $session->cookie_args();
    is( $args->{name}, 'foo-session', 'expired cookie name is correct' );
    is( $args->{value}, $session->id(), 'expired cookie value is session ID' );
    ok( ($args->{expires} < 0), 'expired cookie expires is correct' );
    is( $args->{domain}, 'foo.example.com', 'expired cookie domain is correct' );
    is( $args->{path}, '/bar', 'expired cookie path is correct' );
    is( $args->{secure}, 0, 'expired cookie secure is correct' );
    is( $args->{httponly}, 0, 'expired cookie httponly is correct' );
};

subtest cookie_set_args => sub{
    my $session = $starch->session();

    my $args = $session->cookie_set_args();
    is( $args->{expires}, $expires, 'new session cookie expires is good' );

    $session->force_save();
    $session->expire();
    $args = $session->cookie_set_args();
    is( $args->{expires}, $expires, 'expired session cookie expires is good' );
};

subtest cookie_expire_args => sub{
    my $session = $starch->session();

    my $args = $session->cookie_expire_args();
    ok( ($args->{expires} < 0), 'new session cookie expires is good' );

    $session->force_save();
    $session->expire();
    $args = $session->cookie_expire_args();
    ok( ($args->{expires} < 0), 'expired session cookie expires is good' );
};

subtest expires_default => sub{
    my $starch = Web::Starch->new_with_plugins(
        ['::CookieArgs'],
        store => { class=>'::Memory' },
        expires => 78,
    );

    is( $starch->cookie_expires(), 78, 'cookie_expires defaults to expires' );
};

done_testing;
