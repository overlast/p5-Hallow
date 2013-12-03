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
    my $config = $self->{config};
    my $recipe_name = $self->{recipe_name};
    my $platform = $config->{$recipe_name}->{$module_name}->{platform};
    my $ml_client = "";
    if ($platform eq "jubatus") {
        my $jubatus_conf = $config->{platform}->{jubatus};
        my $server_name = $jubatus_conf->{server_name};
        my $host = $jubatus_conf->{host};
        my $port = $jubatus_conf->{port};
        $server_name =~ s|juba||;
        $ml_client = Jubatus->get_client($host, $port, $server_name);
    }
    return $ml_client;
}

sub get_max_result_num {
    my ($self, $module_name) = @_;
    my $max_result_num = 10; #default
    my $config = $self->{config};
    my $recipe_name = $self->{recipe_name};
    $max_result_num = $config->{$recipe_name}->{$module_name}->{max_result_num} if (exists $config->{$recipe_name}->{$module_name}->{max_result_num});
    return $max_result_num;
}
