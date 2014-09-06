# NAME

File::DirDiff - get diff of a directory between two periods

# SYNOPSIS

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

# DESCRIPTION

File::DirDiff allows you to get the differences of a directory between two periods.

[dirdiff](https://github.com/shoichikaji/File-DirDiff/blob/master/bin/dirdiff)
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

# LIMITATION

Some system (eg: Mac OS X) does not support milli second mtime.
Then this module cannot detect the file modification within a second.

# SEE ALSO

[File::DirCompare](https://metacpan.org/pod/File::DirCompare)

# LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Shoichi Kaji <skaji@cpan.org>
