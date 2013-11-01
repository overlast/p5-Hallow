use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow::Util;

# file mode specification error: (wrong-type-argument listp "\\.\\([pP][Llm]\\|psgi\\|t\\|cgi\\)$")

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
    subtest 'Test read_json_file()' => sub {
        my $tmp_json_path = "/tmp/tmp_json_01_hallow_util.json";
        &write_dummy_json($tmp_json_path);
        if (-f $tmp_json_path) {
            my $json = Hallow::Util::read_json_file($tmp_json_path);
            is(ref $json, "Config::JSON", "get a JSON::Config object");
       }
        &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
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

    subtest 'Test get_config()' => sub {
        my $tmp_json_path = "/tmp/tmp_json_01_hallow_util.json";
        &write_dummy_json($tmp_json_path);
        my $config = Hallow::Util::get_config($tmp_json_path);
        &remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
        is (ref $config, "HASH", "get HASH value which is included in config->{config}");
        is (exists $config->{key}, 1, "this config object have a key property");
        is ($config->{key}, "value", "this config object have a key-value pair");
    };
};

done_testing;
