use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow::Util;

sub write_dummy_json {
    my ($file_path) = @_;
    my $is_write = 0;
    my $tmpl = << "__JSON__";
{
    "key" : "value"
}
__JSON__

    eval {
        open my $out, ">", $file_path;
        print $out $tmpl;
        close $out;
    };
    unless ($@) {
        $is_write = 1;
    }
    return $is_write;
}

sub remove_dummy_json {
    my ($file_path) = @_;
    my $is_remove = 0;
    $is_remove = unlink ($file_path) if (-f $file_path);
    $is_remove = ($is_remove - 1) * -1;
    return $is_remove;
}

subtest 'Test a JSON configure file reader' => sub {
    subtest 'Test get_json_parser()' => sub {
        {
            my $json = Hallow::Util::get_json_parser();
            is (ref $json, "JSON", "Make check to get a JSON object");
        }
    };

    subtest 'Test read_json_file()' => sub {
        {
            my $tmp_json_path = "/tmp/tmp_json_01_hallow_util.json";
            &write_dummy_json($tmp_json_path);
            if (-f $tmp_json_path) {
                my $json = Hallow::Util::read_json_file($tmp_json_path);
                is(ref $json, "Config::JSON", "get a JSON::Config object");
            }
            &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
        }
        {
            my $tmp_json_path = "/tmp/tmp_json_02_hallow_util.json";
            &write_dummy_json($tmp_json_path);
            my $json = Hallow::Util::read_json_file($tmp_json_path."_typo");
            is ($json, "", "get a null character value as file can't find error value");
            &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
        }
        {
            my $tmp_json_path = "/tmp/tmp_json_03_hallow_util.json";
            system("touch $tmp_json_path");
            my $json = Hallow::Util::read_json_file($tmp_json_path);
            is ($json, "", "get a null character value as null file error value");
            &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
        }
        {
            my $json = Hallow::Util::read_json_file("");
            is ($json, "", "get a null character value as null file path error value");
        }
    };

    subtest 'Test complete_file_path()' => sub {
        my $file_name = File::Basename::basename(__FILE__);
        my $dir_name = File::Basename::dirname(__FILE__);
        my $abs_file_path = File::Spec->rel2abs($dir_name)."/".$file_name;
        my $rel_to_abs_path = Hallow::Util::complete_file_path($dir_name."/".$file_name);
        my $already_abs_path = Hallow::Util::complete_file_path($abs_file_path);
        is($rel_to_abs_path, $abs_file_path, "need to complete the path");
        is($already_abs_path, $abs_file_path, "no need to complete the path");
    };

    subtest 'Test get_base_file_name()' => sub {
        my $file_name = File::Basename::basename(__FILE__);
        is(Hallow::Util::get_base_file_name(), $file_name, "get a file name of this test file");
    };

    subtest 'Test get_base_dir_path()' => sub {
        my $dir_path = Hallow::Util::complete_file_path(File::Basename::dirname(__FILE__));
        is(Hallow::Util::get_base_dir_path(), $dir_path, "get a file path of this test file");
    };

    subtest 'Test get_config()' => sub {
        {
            my $tmp_json_path = "/tmp/tmp_json_01_hallow_util.json";
            &write_dummy_json($tmp_json_path);
            my $config = Hallow::Util::get_config($tmp_json_path);
            &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
            is (ref $config, "HASH", "get HASH value which is included in config->{config}");
            is (exists $config->{key}, 1, "this config object have a key property");
            is ($config->{key}, "value", "this config object have a key-value pair");
        }
        {
            my $tmp_json_path = "/tmp/tmp_json_02_hallow_util.json";
            &write_dummy_json($tmp_json_path);
            my $config = Hallow::Util::get_config($tmp_json_path."_typo");
            is ($config, "", "get a null character value as file can't find error value");
            &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
        }
        {
            my $tmp_json_path = "/tmp/tmp_json_03_hallow_util.json";
            system("touch $tmp_json_path");
            my $config = Hallow::Util::get_config($tmp_json_path);
            is ($config, "", "get a null character value as null file error value");
            &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
        }
        {
            my $config = Hallow::Util::get_config("");
            is ($config, "", "get a null character value as null file path error value");
        }
    };

    subtest 'Test add_leading_zeros()' => sub {
        is(Hallow::Util::add_leading_zeros(0, 2), "00", "make check to add leading zeros to make 2 digits num 0 => 00");
        is(Hallow::Util::add_leading_zeros(10, 2), "10", "make check to add leading zeros to make 2 digits num 10 => 10");
        is(Hallow::Util::add_leading_zeros(10, 4), "0010", "make check to add leading zeros to make 4 digits num 10 => 0010");
        is(Hallow::Util::add_leading_zeros(1000, 4), "1000", "make check to add leading zeros to make 4 digits num 1000 => 1000");
        is(Hallow::Util::add_leading_zeros(100, 3), "100", "make check to add no leading zero to make 3 digits num 100 => 100");
        is(Hallow::Util::add_leading_zeros(1000, 3), "1000", "make check to add no leading zero to make 3 digits num 1000 => 1000");
    };
};

done_testing;
