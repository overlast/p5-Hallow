package Hallow::Client;

use 5.008005;
use strict;
use warnings;

our $VERSION = "0.0.0_01";

use utf8;
use autodie;

use constant HALLOW_DEBUG => $ENV{HALLOW_DEBUG};
use Log::Minimal qw/debugf infof warnf critf/; # $ENV{LM_DEBUG}
use Log::Minimal::Indent; # call indent_log_scope("any", "MUTE");
local $Log::Minimal::AUTODUMP = 1;
local $Log::Minimal::COLOR = 1;
local $Log::Minimal::LOG_LEVEL = "DEBUG";

use Data::Validator::Recursive;

use Jubatus;

use Hallow::Util;


=pod
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
=cut

sub _show_validate_error {
    my ($rule) = @_;
    foreach my $error (@{$rule->{errors}}) {
        warnf $error->{message};
    }
}

sub new {
    my ($class, $param) = @_;
    my $hash = {};
    # $paramは空でも問題ない。ただし与えるならHASH refで。
    {
        my $rule = Data::Validator::Recursive->new(
            "config_file_path" => "Str",
            "recipe_name" => "Str",
        )->with('AllowExtra');
        if ((defined $param) && (ref $param eq "HASH")) {
            if ($rule->validate($param)) {
                $hash = $param;
            } else { _show_validate_error($rule) if (HALLOW_DEBUG); }
        } else { warnf "First argument should be define as HASH ref" if (HALLOW_DEBUG); }

        # new()を実行したファイルのあるディレクトリを獲得
        $hash->{base_dir_path} = Hallow::Util::get_base_dir_path();
        # 共通の JSON インスタンスを獲得
        $hash->{json} = Hallow::Util::get_json_parser(); # to UTF8 flagged decode

        # 必須な設定ファイルの読み込み
        if ((exists $hash->{config_file_path}) && (-f $hash->{config_file_path})) {
            $hash->{config} = Hallow::Util::get_config($hash->{config_file_path});
        } else {
            if (HALLOW_DEBUG) {
                warnf "hash->{config_file_path} should be define" unless (exists $hash->{config_file_path});
                warnf "hash->{config_file_path} should be define as a path of configure file" unless ((exists $hash->{config_file_path}) && (-f $hash->{config_file_path}));
            }
        }
    }
    return bless $hash, $class;
}

sub get_ml_client {
    my ($self, $module_name) = @_;
    my $ml_client = "";
    my $config = $self->{config};
    if (exists $self->{recipe_name}) {
        if (defined $module_name) {
            my $recipe_name = $self->{recipe_name};
            {
                my $rule = Data::Validator::Recursive->new(
                    "$recipe_name" => {
                        "isa" => "HashRef",
                        "rule" => [
                            "$module_name" => { "isa" => "HashRef", "rule" => [ "platform" => "Str", ], },
                        ],
                    },
                    "recipe" => { "isa" => "HashRef", },
                    "platform" => { "isa" => "HashRef", }
                )->with('AllowExtra');
                if ($rule->validate($config)) {
                    my $platform = $config->{$recipe_name}->{$module_name}->{platform};
                    if ($platform =~ m|jubatus|i) {
                        my $jubatus_conf = $config->{platform}->{jubatus};
                        my $type = $jubatus_conf->{type};
                        my $host = $jubatus_conf->{host};
                        my $port = $jubatus_conf->{port};
                        my $name = $jubatus_conf->{name};
                        my $timeout = $jubatus_conf->{timeout};
                        $ml_client = Jubatus->get_client($type, $host, $port, $name, $timeout);
                    } else { warnf "config->{$recipe_name}->{$module_name}->{platform} should be (|jubatus|i)" if (HALLOW_DEBUG); }
                } else { _show_validate_error($rule) if (HALLOW_DEBUG); }
            }
        } else { warnf "First argument of get_ml_client() should be a module name" if (HALLOW_DEBUG); }
    } else { warnf "self->{recipe_name} should be define in a constructor" if (HALLOW_DEBUG); }
    return $ml_client;
}

sub get_max_result_num {
    my ($self, $module_name) = @_;
    # 設定ファイルから件数を読めない時は10と返す
    my $max_result_num = 10; #default
    my $config = $self->{config};
    # recipe_name がHallow::Client以下のnew()で指定されている必要がある
    if (exists $self->{recipe_name}) {
        my $recipe_name = $self->{recipe_name};
        # module_nameが定義されている必要がある
        if (defined $module_name) {
            # config->{$recipe_name}->{$module_name}が定義されている必要がある
            if (exists $config->{$recipe_name}->{$module_name}) {
                # max_result_num で設定ファイルから件数を読み込む
                if (exists $config->{$recipe_name}->{$module_name}->{max_result_num}) {
                    $max_result_num = $config->{$recipe_name}->{$module_name}->{max_result_num};
                } else { warnf "config->{$recipe_name}->{$module_name}->{max_result_num} should be define in configure file" if (HALLOW_DEBUG); }
            } else { warnf "First argument of get_max_result_num() is module_name" if (HALLOW_DEBUG); }
        } else { warnf "config->{$recipe_name}->{module_name} should be define in configure file" if (HALLOW_DEBUG); }
    } else { warnf "self->{recipe_name} should be define in constructor" if (HALLOW_DEBUG); }
    return $max_result_num;
}
