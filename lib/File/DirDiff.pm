package File::DirDiff;
use 5.008001;
use strict;
use warnings;
use File::Find 'find';
use Time::HiRes ();

our $VERSION = "0.01";

sub new {
    my ($class, %arg) = @_;
    my $dir  = $arg{dir} or die "Missing dir option";
    my $init = exists $arg{init} ? $arg{init} : 1;
    my $self = bless { dir => $dir }, $class;
    $self->init if $init;
    $self;
}

sub _find {
    my $self = shift;
    my $result = {};
    my $wanted = sub {
        my $name = $File::Find::name;
        my $type = -l $name ? "symlink"
                 : -f $name ? "file"
                 : -d $name ? "dir"
                 :            "unknown";
        my $mtime = $type eq "symlink" ? (Time::HiRes::lstat $name)[9]
                  :                      (Time::HiRes::stat  $name)[9];
        my $symlink = $type eq "symlink" ? readlink $name : undef;
        $result->{$name} = {
            name => $name,
            type => $type,
            mtime => $mtime,
            ( $symlink ? (symlink => $symlink) : () ),
        };
    };
    find { wanted => $wanted, no_chdir => 1 }, $self->{dir};
    return $result;
}

sub init {
    my $self = shift;
    delete $self->{$_} for qw(before after);
    $self->{before} = $self->_find;
}

sub diff {
    my ($self, $cb) = @_;
    my $before = $self->{before} or die;
    my $after = $self->{after} = $self->_find;

    my %seen;
    for my $name (sort keys %$before) {
        my $old = $before->{$name};
        if (my $new = $after->{$name}) {
            if ( $old->{mtime} != $new->{mtime}
                && !( $old->{type} eq "dir" && $new->{type} eq "dir" )
            ) {
                $cb->($old, $new);
            }
        } else {
            $cb->($old, undef);
        }
        $seen{$name}++;
    }
    for my $name (grep { !$seen{$_} } sort keys %$after) {
        $cb->(undef, $after->{$name});
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

File::DirDiff - get diff of a directory between two periods

=head1 SYNOPSIS

    use File::DirDiff;

    # register watch directory
    my $watcher = File::DirDiff->new( dir => "$ENV{HOME}/local" );

    # do something
    system "./configure --prefix=$ENV{HOME}/local && make install";

    # diff!
    $watcher->diff(sub {
        my ($old, $new) = @_;
        if (!$new) {
            say "deleted $old->{name}";
        } elsif (!$old) {
            say "added $new->{name}";
        } else {
            say "modified $old->{name}";
        }
    });


=head1 DESCRIPTION

File::DirDiff allows you to get the differences of a directory between two periods.

L<dirdiff|https://github.com/shoichikaji/File-DirDiff/blob/master/bin/dirdiff>
script, which reports the specified direcoty diff after some command execution,
is available:

    > wget https://raw.githubusercontent.com/shoichikaji/File-DirDiff/master/dirdiff
    > chmod +x dirdiff

    # eg:
    > ./dirdiff $HOME/local bash -c "./configure --prefix=$HOME/local && make install"
    ...
    A /home/skaji/local/bin/hoge
    M /home/skaji/local/bin/foo
    A /home/skaji/local/lib/libhoge.so

=head1 LIMITATION

Some system (eg: Mac OS X) does not support milli second mtime.
Then this module cannot detect the file modification within a second.

=head1 SEE ALSO

L<File::DirCompare>

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@cpan.orgE<gt>

=cut

