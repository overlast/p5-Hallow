use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow;

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

use YAML;
subtest 'Test a constructor' => sub {
    subtest 'Test new()' => sub {
        {
            my $h = Hallow->new();
            is (ref $h, "Hallow", "Make check to get Hallow object")
        }
        {
            my $h = Hallow->new();
            is (exists $h->{base_dir_path}, 1, "Make check a base directory path is already defined");
            is ((-d $h->{base_dir_path}), 1, "Make check the directory which define as h->{base_dir_path} is there");
        }
        {
            my $param = {
                "config_file_path" => "/tmp/tmp_json_06_hallow.json",
                "recipe" => "estimate",
            };
            my $h = Hallow->new($param);
            is (exists $h->{config_file_path}, 1, "Make check a configure file path is already defined");
            is (exists $h->{recipe}, 1, "Make check a name of recipe is already defined");
            is (exists $h->{config}, "", "Make check self->{config} field needs what the config file is there");
        }
        {
            my $tmp_json_path = "/tmp/tmp_json_06_hallow.json";
            &write_dummy_json($tmp_json_path);
            my $param = {
                "config_file_path" => $tmp_json_path,
                "recipe" => "estimate",
            };
            my $h = Hallow->new($param);
            &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
            is (exists $h->{config}, 1, "Make check self->{config} is defined");
        }
    };
};




#            print Dump $h;

=pod

subtest 'Test a JSON configure file reader' => sub {
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

=cut

done_testing;
