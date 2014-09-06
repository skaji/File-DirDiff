use strict;
use warnings;
use utf8;
use Test::More;
use File::DirDiff;
use File::Temp 'tempdir';
use File::Path qw(mkpath rmtree);
use Data::Dumper;
sub spew {
    my $file = shift;
    my $str  = shift || "";
    open my $fh, ">", $file or die "$file: $!";
    print {$fh} $str;
}

my $tempdir = tempdir CLEANUP => 1;
spew "$tempdir/hoge1";
spew "$tempdir/hoge2";
mkpath "$tempdir/dir1/dir11";
spew "$tempdir/dir1/dir11/foo";
mkpath "$tempdir/dir2";
symlink "$tempdir/dir1", "$tempdir/link1";
symlink "$tempdir/notexists", "$tempdir/link2";

my $watcher = File::DirDiff->new(dir => $tempdir);
sleep 2;

spew "$tempdir/hoge1", "changed";
spew "$tempdir/new1";
unlink "$tempdir/hoge2";
rmtree "$tempdir/dir1";
unlink "$tempdir/link1";
symlink "$tempdir/hoge1", "$tempdir/link1";

my $times = 0;
$watcher->diff(sub {
    $times++;
    diag Dumper \@_;
});

is $times, 7;


pass "Ok";




done_testing;
