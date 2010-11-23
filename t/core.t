#!perl

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::ModuleLoader;
use Dancer::Session::KiokuDB;

use Test::More tests => 4, import => ['!pass'];
use Test::Fatal;
use Test::TinyMocker;

like(
    exception { Dancer::Session::KiokuDB->new },
    qr/^Missing kiokudb_backend_opts/,
    'kiokudb_backend_opts is required',
);

set kiokudb_backend_opts => [];

like(
    exception { Dancer::Session::KiokuDB->new },
    qr/^kiokudb_backend_opts must be a hash reference/,
    'kiokudb_backend_opts should be hashref',
);

SKIP: {
    skip 'The following tests require KiokuDB::Backend::DBI' => 2
        unless Dancer::ModuleLoader->load('KiokuDB::Backend::DBI');

    skip 'The following tests require File::Temp' => 2
        unless Dancer::ModuleLoader->load('File::Temp');

    my ( $fh, $file ) = File::Temp::tempfile;
    close $fh or die "Can't close $file: $!\n";

    my $dsn = "dbi:SQLite:dbname=$file";

    set kiokudb_backend_opts => { dsn => $dsn };

    my $session;
    is(
        exception { $session = Dancer::Session::KiokuDB->new },
        undef,
        'Create session object successfully',
    );

    isa_ok( $session, 'Dancer::Session::KiokuDB' );

    unlink $file;
};

