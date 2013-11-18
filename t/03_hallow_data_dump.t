use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow::Data::Dump;
use Hallow::DateTime;

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
        my $dir_path = "/tmp/03_hallow_data_dump_mkdirp/";
        is(-d $dir_path, undef, "Make check $dir_path is not there(= undef)");
        Hallow::Data::Dump::mkdirp($dir_path);

        my $dt = Hallow::DateTime::get_dt("20221010T23:59:59");

        {
            my $param = {
                "type" => "dump_file",
                "file_ext" => "json",
                "delay_to_process" => 300,
                "file_split_type" => "10min",
                "wait_n_times" => "1",
                "is_use_daily_directory" => "1",
                "dump_dir_path" => "data/related_items/vector/",
            };
            my $dump_dir_path = Hallow::Data::Dump::get_dump_dir_path($param, $dir_path, $dt);
            is($dump_dir_path, "/tmp/03_hallow_data_dump_mkdirp/data/related_items/vector/20221010/", "Make check to return a dump directly path with is_use_daily_directory flag");
            is((-d $dump_dir_path), 1, "Make check to make a dump directly");
        }

        {
            my $param = {
                "type" => "dump_file",
                "file_ext" => "json",
                "delay_to_process" => 300,
                "file_split_type" => "10min",
                "wait_n_times" => "1",
                "is_use_daily_directory" => "0",
                "dump_dir_path" => "data/related_items/vector/",
            };
            my $dump_dir_path = Hallow::Data::Dump::get_dump_dir_path($param, $dir_path, $dt);
            is($dump_dir_path, "/tmp/03_hallow_data_dump_mkdirp/data/related_items/vector/", "Make check to return a dump directly path");
            is((-d $dump_dir_path), 1, "Make check to make a dump directly");
        }

        {
            my $param = {
                "type" => "dump_file",
                "file_ext" => "json",
                "delay_to_process" => 300,
                "file_split_type" => "10min",
                "wait_n_times" => "1",
                "dump_dir_path" => "data/related_items/vector/",
            };
            my $dump_dir_path = Hallow::Data::Dump::get_dump_dir_path($param, $dir_path, $dt);
            is($dump_dir_path, "/tmp/03_hallow_data_dump_mkdirp/data/related_items/vector/20221010/", "Make check to return a dump directly when param->is_use_daily_directory field isn't exists");
            is((-d $dump_dir_path), 1, "Make check to make a dump directly");
        }

        {
            my $param = {
                "type" => "dump_file",
                "file_ext" => "json",
                "delay_to_process" => 300,
                "file_split_type" => "10min",
                "wait_n_times" => "1",
                "dump_dir_path" => "/tmp/03_hallow_data_dump_mkdirp/",
            };
            my $dump_dir_path = Hallow::Data::Dump::get_dump_dir_path($param, $dir_path, $dt);
            is($dump_dir_path, "/tmp/03_hallow_data_dump_mkdirp/20221010/", "Make check to return a dump directly when dump_dir_path field is absolute path");
            is((-d $dump_dir_path), 1, "Make check to make a dump directly");
        }

        {
            my $param = {
                "type" => "dump_file",
                "file_ext" => "json",
                "delay_to_process" => 300,
                "file_split_type" => "10min",
                "wait_n_times" => "1",
                "dump_dir_path" => "data/related_items/vector/",
            };
            {
                my $dump_dir_path = Hallow::Data::Dump::get_dump_dir_path($param, $dir_path, "");
                is($dump_dir_path, "", "Make check to return null character value as a message of no DateTime object error");
            }
            {
                my $dump_dir_path = Hallow::Data::Dump::get_dump_dir_path($param, "", $dt);
                is($dump_dir_path, "", "Make check to return null character value as a message of no base directory error");
            }
            {
                my $dump_dir_path = Hallow::Data::Dump::get_dump_dir_path([], $dir_path, $dt);
                is($dump_dir_path, "", "Make check to return null character value as a message of no HASH param error");
            }
            {
                my $dump_dir_path = Hallow::Data::Dump::get_dump_dir_path({}, $dir_path, $dt);
                is($dump_dir_path, "", "Make check to return null character value as a message of no param->{dump_dir_path} field error");
            }
        }

        system ("rm -r $dir_path");
        is(-d $dir_path, undef, "Make check $dir_path is removed(= undef)");

    };
};

done_testing;
