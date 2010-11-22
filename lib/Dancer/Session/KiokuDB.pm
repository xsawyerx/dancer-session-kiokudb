use strict;
use warnings;
package Dancer::Session::KiokuDB;
# ABSTRACT: KiokuDB Dancer session backend

use Carp;
use base 'Dancer::Session::Abstract';

# to have access to configuration data and a helper for paths
use KiokuDB;
use Search::GIN::Extract::Class;
use Search::GIN::Extract::Attributes;
use Search::GIN::Extract::Multiplex;

use Dancer::Logger;
use Dancer::Config    'setting';
use Dancer::FileUtils 'path';
use Dancer::ModuleLoader;

my $db;

sub init {
    my $self    = shift;
    my $backend = setting('kiokudb_backend') || 'DBI';
    my $class   = "KiokuDB::Backend::$backend";
    my %opts    = ();

    if ( my $opts = setting('kiokudb_backend_opts') ) {
        if ( ref $opts and ref $opts eq 'HASH' ) {
            %opts = %{$opts};
        }
    }

    defined $opts{'create'} or $opts{'create'} = 1;

    Dancer::Logger::warning("Did not provide default session KiokuDB backend");
    Dancer::Logger::warning("Using default: 'DBI'");

    Dancer::ModuleLoader->load($class)
        or croak "Cannot load $class: perhaps you need to install it?";

    $db = KiokuDB->new(
        backend => $class->new(%opts),
    );
}

sub create {
    my $class = shift;
    my $self  = $class->new;

    $self->flush;

    return $self;
}

sub retrieve {
    my $self  = shift;
    my ($id)  = @_;
    my $scope = $db->new_scope;

    # return object
    return $db->retrieve($id);
}

sub destroy {
    my $self = shift;

    $db->delete($self);
}

sub flush {
    my $self  = shift;
    my $id    = delete $self->{'id'};
    my $scope = $db->new_scope;

    return $db->insert( id => $self );
}



1;

__END__

=head1 SYNOPSIS

    # in your Dancer app:
    setting session              => 'KiokuDB';
    setting kiokudb_backend      => 'DBI';
    setting kiokudb_backend_opts => {
        dsn => 'dbi:SQLite:dbname=mydb.sqlite',
    };

    # or in your Dancer config file:
    session:         'KiokuDB'
    kiokudb_backend: 'DBI'
    kiokudb_backend_opts:
        dsn: 'dbi:SQLite:dbname=mydb.sqlite'

=head1 DESCRIPTION

When you want to save session information, you can pick from various session
backends, and they each determine how the session information will be saved. You
can use L<Dancer::Session::Cookie> or L<Dancer::Session::MongoDB> or you can now
use L<Dancer::Session::KiokuDB>.

This backend uses L<KiokuDB> to save and access session data.

=head1 SUBROUTINES/METHODS

=head2 init

Initializes the object by loading the proper KiokuDB backend and creating the
initial connection.

=head2 create

Creates a new object, runs C<flush> and returns the object.

=head2 flush

Writes the session information to the KiokuDB session database.

=head2 retrieve

Retrieves session information from the KiokuDB session database.

=head2 destroy

Deletes session information from the KiokuDB session database.

=head1 SEE ALSO

The Dancer Advent Calendar 2010.
