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

use Jubatus;

use Hallow::Util;

sub new {
    my ($class, $param) = @_;
    my $hash = {};

    # $paramは空でも問題ない。ただし与えるならHASH refで。
    if (defined $param) {
        if (ref $param eq "HASH") {
            $hash = $param;
        } else {
            warnf "First argument should be define as HASH ref" if (HALLOW_DEBUG);
        }
    }

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
            warnf "hash->{config_file_path} should be define as the path to configure file" unless (-f $hash->{config_file_path});
        }
    }
    return bless $hash, $class;
}

sub get_ml_client {
    my ($self, $module_name) = @_;
    my $ml_client = "";
    my $config = $self->{config};
    if (exists $self->{recipe_name}) {
        my $recipe_name = $self->{recipe_name};
        if (defined $module_name) {
            if (exists $config->{$recipe_name}->{$module_name}) {
                if (exists $config->{$recipe_name}->{$module_name}->{platform}) {
                    my $platform = $config->{$recipe_name}->{$module_name}->{platform};
                    if ($platform =~ m|jubatus|i) {
                        my $jubatus_conf = $config->{platform}->{jubatus};
                        my $server_name = $jubatus_conf->{server_name};
                        my $host = $jubatus_conf->{host};
                        my $port = $jubatus_conf->{port};
                        $server_name =~ s|juba||;
                        $ml_client = Jubatus->get_client($host, $port, $server_name);
                    } else {
                        warnf "config->{$recipe_name}->{$module_name}->{platform} should be (|jubatus|i)" if (HALLOW_DEBUG);
                    }
                } else {
                    warnf "config->{$recipe_name}->{$module_name}->{platform} should be define in a configure file" if (HALLOW_DEBUG);
                }
            } else {
                warnf "config->{$recipe_name}->{module_name} should be define in a configure file" if (HALLOW_DEBUG);
            }
        } else {
            warnf "First argument of get_ml_client() should be a module name" if (HALLOW_DEBUG);
        }
    } else {
        warnf "self->{recipe_name} should be define in a constructor" if (HALLOW_DEBUG);
    }
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
                } else {
                    warnf "config->{$recipe_name}->{$module_name}->{max_result_num} should be define in configure file" if (HALLOW_DEBUG);
                }
            } else {
                warnf "First argument of get_max_result_num() is module_name" if (HALLOW_DEBUG);
            }
        } else {
            warnf "config->{$recipe_name}->{module_name} should be define in configure file" if (HALLOW_DEBUG);
        }
    } else {
        warnf "self->{recipe_name} should be define in constructor" if (HALLOW_DEBUG);
    }
    return $max_result_num;
}
