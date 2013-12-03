use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow::Client;

my $app_conf = << "__APP_JSON__";
{
    "recipe" : {
        "seed" : ["item_db"],
        "feature" : ["related_items_vector"],
        "estimate" : ["related_items_result"]
    },
    "platform" : {
        "jubatus" : {
            "server_name" : "jubarecommender",
            "config_file_path" : "/tmp/tmp_jubatus_conf_06_hallow.json",
            "app_name" : "item_recommend",
            "host" : "localhost",
            "port" : 57200,
            "dump" : "load"
        },
    },
    "estimate" : {
        "related_items_result" : {
            "start_ymdhms" : "2022-10-10T23:59:59",
            "delay_seconds" : 600,
            "time_cycle_type" : "10min",
            "is_cut_surplus" : 1,
            "output" : {
                "to" : ["related_items_result"],
                "related_items_result" : {
                    "media_type" : "file",
                    "dump_file_ext" : "json",
                    "delay_to_process" : 300,
                    "time_cycle_type" : "10min",
                    "wait_n_times" : "1",
                    "is_daily_directory" : "1",
                    "dump_dir_path" : "data/related_items/result/",
                    "platform" : "jubatus",
                }
            },
            "input" : {
                "from" : ["related_items_vector"],
                "related_items_vector" : {
                    "media_type" : "file",
                    "file_ext" : "json",
                    "platform" : "jubatus",
                    "seed_config" : "brand_db",
                    "delay_to_process" : 300,
                    "time_cycle_type" : "10min",
                    "wait_n_times" : "1",
                    "is_daily_directory" : "1",
                    "dump_dir_path" : "data/related_items/vector/",
                }
            },
            "max_result_num" : 30,
            "platform" : "jubatus",
            "wait_n_times" : "1",
            "is_daily_directory" : "1",
            "label" : {
                "column_name" : "id",
            },
        }
    },
}
__APP_JSON__

    my $jubatus_conf = << "__JUBA_JSON__";
{
    "converter" : {
        "string_filter_types": {
        },
        "string_filter_rules":[
        ],
        "num_filter_types": {},
        "num_filter_rules": [],
        "string_types": {
            "mecab": {
                "method": "dynamic",
                "path": "libmecab_splitter.so",
                "function": "create",
                "arg": "-d /usr/lib64/mecab/dic/ipadic"
            },
            "bigram":  { "method": "ngram", "char_num": "2" },
            "trigram":  { "method": "ngram", "char_num": "3" }
        },
        "string_rules":[
            { "key": "ngram_*", "type": "trigram", "sample_weight": "tf",  "global_weight": "bin" },
            { "key": "ma_*", "type": "mecab", "sample_weight": "tf",  "global_weight": "bin" },
            { "key" : "*", "type" : "str", "sample_weight":"bin", "global_weight" : "bin"}
        ],
        "num_types": {},
        "num_rules": [
            {"key" : "*", "type" : "num"}
        ]
    },
    "method": "inverted_index"
}
__JUBA_JSON__

sub _write_dummy_json {
    my ($file_path, $data) = @_;
    my $is_write = 0;
    eval {
        open my $out, ">", $file_path;
        print $out $data;
        close $out;
    };
    unless ($@) {
        $is_write = 1;
    }
    return $is_write;
}

sub _remove_dummy_json {
    my ($file_path) = @_;
    my $is_remove = 0;
    $is_remove = unlink ($file_path) if (-f $file_path);
    $is_remove = ($is_remove - 1) * -1;
    return $is_remove;
}

subtest 'Test a constructor' => sub {
    subtest 'Test new()' => sub {
        {
            my $h = Hallow::Client->new();
            is (ref $h, "Hallow::Client", "Make check to get Hallow::Client object")
        }
        {
            my $h = Hallow::Client->new();
            is (exists $h->{base_dir_path}, 1, "Make check a base directory path is already defined");
            is ((-d $h->{base_dir_path}), 1, "Make check the directory which define as h->{base_dir_path} is there");
        }
        {
            my $param = {
                "config_file_path" => "/tmp/tmp_json_06_hallow.json",
                "recipe" => "estimate",
            };
            my $h = Hallow::Client->new($param);
            is (exists $h->{config_file_path}, 1, "Make check a configure file path is already defined");
            is (exists $h->{recipe}, 1, "Make check a name of recipe is already defined");
            is (exists $h->{config}, "", "Make check self->{config} field needs what the config file is there");
        }
        {
            my $param = {
                "config_file_path" => "/tmp/tmp_json_06_hallow.json",
                "recipe" => "estimate",
            };
            my $h = Hallow::Client->new($param);
            is (exists $h->{json}, 1, "Make check json field exists in Hallow::Client object");
            is (ref $h->{json}, "JSON", "Make check json field has JSON object");
        }
        {
            my $tmp_json_path = "/tmp/tmp_json_06_hallow.json";
            &_write_dummy_json($tmp_json_path, $app_conf);
            my $param = {
                "config_file_path" => $tmp_json_path,
                "recipe" => "estimate",
            };
            my $h = Hallow::Client->new($param);
            &_remove_dummy_json($tmp_json_path) if (-f $tmp_json_path);
            is (exists $h->{config}, 1, "Make check self->{config} is defined");
        }
    };
};

=pod

subtest 'Test to get the module parameters set' => sub {
    subtest 'Test start()' => sub {
        {
            my $tmp_app_conf_path = "/tmp/tmp_app_conf_06_hallow.json";
            my $tmp_jubatus_conf_path = "/tmp/tmp_jubatus_conf_06_hallow.json";
            &_write_dummy_json($tmp_app_conf_path, $app_conf);
            &_write_dummy_json($tmp_jubatus_conf_path, $jubatus_conf);
            my $param = {
                "config_file_path" => $tmp_app_conf_path,
                "recipe_name" => "estimate",
            };
            my $h = Hallow->new($param);
            &_remove_dummy_json($tmp_app_conf_path) if (-f $tmp_app_conf_path);
            my $recipe_map = $h->_get_recipe_map(); # ["related_items_result"]
            foreach my $module_name (@{$recipe_map}) {
                my $module_param = $h->_get_module_param($module_name);
                my $is_done = $h->start($module_name, $module_param);
                is($is_done, -1, "Make check return value is -1 as a return value of action() which is a stub method");
            }
            &_remove_dummy_json($tmp_jubatus_conf_path) if (-f $tmp_jubatus_conf_path);
        }
    };
};





#            print Dump $h;


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
