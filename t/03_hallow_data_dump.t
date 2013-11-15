use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow::Data::Dump;

subtest 'Test to make an arbitrary directory' => sub {
    subtest 'Test mkdirp()' => sub {
        my $dir_path = "/tmp/03_hallow_data_dump_mkdirp/";
        is(-d $dir_path, undef, "Make check $dir_path is not there(= undef)");
        Hallow::Data::Dump::mkdirp($dir_path);
        is(-d $dir_path, 1, "Make check $dir_path was made by mkdirp()");
        system ("rm -r $dir_path");
        is(-d $dir_path, undef, "Make check $dir_path is removed(= undef)");
    };
};

subtest 'Test to get an arbitrary directory which is used to store dump files' => sub {
    subtest 'Test get_dump_dir_path()' => sub {

    };
};

done_testing;
