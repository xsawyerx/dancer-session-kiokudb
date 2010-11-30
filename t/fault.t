#!perl

use strict;
use warnings;

use Dancer ':syntax';
use Dancer::ModuleLoader;
use Dancer::Session::KiokuDB;

use Test::More tests => 2, import => ['!pass'];
use Test::Fatal;

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

