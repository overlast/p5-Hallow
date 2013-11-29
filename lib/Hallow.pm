package Hallow;

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

use Coro;
use Coro::Timer;

use JSON;

use Hallow::Util;
use Hallow::DateTime;
use Hallow::Data::Handle;
use Hallow::Data::Dump;

# インスタンスの初期化をする
# Hallowを継承したクラスから呼ぶフレームワーク内のクラスで頻繁に使う値を格納する
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
    $hash->{json} = JSON->new->utf8(1)->allow_nonref; # to UTF8 flagged decode

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

sub ignition {
    my ($self) = @_;
    my $message = 0;
    if ((exists $self->{config}) && (ref $self->{config} eq "HASH")) {
        $self->sequence();
        $message = 1;
    } else {
        if (HALLOW_DEBUG) {
            warnf "self->{config} should be exists" unless (exists $self->{config});
            warnf "self->{config} should be Hash ref" unless (ref $self->{config} eq "HASH");
        }
    }
    return $message;
}

sub _get_recipe_map {
    my ($self) = @_;
    my $result = "";
    if (exists $self->{recipe_name}) {
        if (exists $self->{config}->{recipe}->{$self->{recipe_name}}) {
            if (ref $self->{config}->{recipe}->{$self->{recipe_name}} eq "ARRAY") {
                $result = $self->{config}->{recipe}->{$self->{recipe_name}};
            } else {
                warnf "self->config->recipe->recipe_name is not ARRAY ref" if (HALLOW_DEBUG);
            }
        } else {
            warnf "Can't get recipe from self->config->recipe->recipe_name" if (HALLOW_DEBUG);
        }
    } else {
        warnf "Can't get self->recipe_name" if (HALLOW_DEBUG);
    }
    return $result;
}

sub _get_module_param {
    my ($self, $module_name) = @_;
    my $param = "";
    if (exists $self->{recipe_name}) {
        my $recipe_name = $self->{recipe_name};
        if ((defined $module_name) && ($module_name) && (exists $self->{config}->{$recipe_name}->{$module_name})) {
            $param = $self->{config}->{$recipe_name}->{$module_name};
        } else {
            warnf "Can't get module parameter from self->config->recipe_name->module_name" if (HALLOW_DEBUG);
        }
    } else {
        warnf "Can't get self->recipe_name" if (HALLOW_DEBUG);
    }
    return $param;
}

sub _get_initial_dt {
    my ($self, $param) = @_;
    my $dt = "";
    if (ref $param eq "HASH") {
        if (exists $param->{start_ymdhms}) {
            $dt = Hallow::DateTime::get_dt($param->{start_ymdhms});
        } else {
            $dt = Hallow::DateTime::get_dt();
        }
        if (ref $dt eq "DateTime") {
            $dt = Hallow::DateTime::get_prev_dt($dt, $param);
            if (ref $dt eq "DateTime") {
                $dt = Hallow::DateTime::add_delay_seconds_to_dt($dt, $param);
            } else {
                warnf "Can't get DateTime object from get_prev_dt()" if (HALLOW_DEBUG);
            }
        } else {
            warnf "Can't get DateTime object from get_dt()" if (HALLOW_DEBUG);
        }
    } else {
        warnf "Can't get parameters to initialize DateTime object" if (HALLOW_DEBUG);
    }
    return $dt;
}

sub sequence {
    my ($self) = @_;
    my %next_dt_map = ();
    my $config = $self->{config};
    my $base_dir_path = $self->{base_dir_path};
    my $is_last_of_sequence = 0;
    async {
        infof ("boot sequence() ...") if (HALLOW_DEBUG);
        my $timeout = Coro::Timer::timeout(0);
        while (1) {
            while (1) {
                Coro::schedule; # wait until woken up or timeout
                foreach my $module_name (@{$self->_get_recipe_map()}) {
                    my $module_param = $self->_get_module_param($module_name);
                    my $dt = $self->_get_initial_dt($module_param);
                    $self->{current_dt} = $dt;
                    if (exists $next_dt_map{$module_name}) {
                        next unless (Hallow::DateTime::is_first_dt_future($dt, $next_dt_map{$module_name}));
                        if ((exists $module_param->{end_ymdhms}) && (
                            Hallow::DateTime::is_first_dt_future($dt, Hellow::DateTime::get_dt($module_param->{end_ymdhms})
                                                             ))) {
                            infof "Exit sequence() because time_stamp > module_param->{end_ymdhms}" if (HALLOW_DEBUG);
                            $is_last_of_sequence = 1; last;
                        }
                        my $next_dt = Hellow::DateTime::get_next_dt($next_dt_map{$module_name}, $module_param);
                        if (ref $next_dt eq "DateTime") {
                            $next_dt_map{$module_name} = $next_dt;
                        } else {
                            warn "Can't get DateTime object by get_next_dt()" if (HALLOW_DEBUG);
                            $is_last_of_sequence = 1; last;
                        }
                        infof ("start() to process...") if (HALLOW_DEBUG);
                        $self->start($module_name);
                    }
                }
                if (($is_last_of_sequence) || ($timeout)) {
                    $timeout = Coro::Timer::timeout(3); last;
                }
            }
            if ($is_last_of_sequence) {
                warnf "exit sequence() ..." if (HALLOW_DEBUG);
                return;
            }
        }
    };
    while (1) {
        Coro::schedule;
    }
    return;
}

sub _get_module_input_params {
    my ($self, $module_param) = @_;
    my $param = "";
    if (ref $module_param eq "HASH") {
        if ((exists $module_param->{input}) && ($module_param->{input}->{from})) {
            my $param_names = $module_param->{input}->{from};
            if (ref $param_names eq "ARRAY") {
                my @params = ();
                foreach my $param_name (@{$param_names}) {
                    if (exists $module_param->{input}->{$param_name}) {
                        if (exists $module_param->{input}->{$param_name}->{media_type}) {
                            my $tmp_param = $module_param->{input}->{$param_name};
                            push @params, $tmp_param;
                        }  else {
                            warnf "module_param->{input}->{$param_name}->{media_type} field should be there" if (HALLOW_DEBUG);
                        }
                    } else {
                        warnf "module_param->{input}->{$param_name} field should be there" if (HALLOW_DEBUG);
                    }
                    $param = \@params;
                }
            }
            else {
                if (exists $module_param->{input}->{$param_names}) {
                    if (exists $module_param->{input}->{$param_names}->{media_type}) {
                        $param = [$module_param->{input}->{$param_names}];
                    } else {
                        warnf "module_param->{input}->{$param_names}->{media_type} field should be there" if (HALLOW_DEBUG);
                    }
                } else {
                    warnf "module_param->{input}->{$param_names} field should be there" if (HALLOW_DEBUG);
                }
            }
       } else {
            warnf "first argument must have param->{input}->{from} field" if (HALLOW_DEBUG);
        }
    } else {
        warnf "first argument must be HASH ref" if (HALLOW_DEBUG);
    }
    return $param;
}

sub _get_module_output_params {
    my ($self, $module_param) = @_;
    my $param = "";
    if (ref $module_param eq "HASH") {
        if ((exists $module_param->{output}) && ($module_param->{output}->{to})) {
            my $param_names = $module_param->{output}->{to};
            if (ref $param_names eq "ARRAY") {
                my @params = ();
                foreach my $param_name (@{$param_names}) {
                    if (exists $module_param->{output}->{$param_name}) {
                        if (exists $module_param->{output}->{$param_name}->{media_type}) {
                            my $tmp_param = $module_param->{output}->{$param_name};
                            push @params, $tmp_param;
                        } else {
                            warnf "module_param->{output}->{$param_name}->{media_type} field should be there" if (HALLOW_DEBUG);
                        }
                    } else {
                        warnf "module_param->{output}->{$param_name} field should be there" if (HALLOW_DEBUG);
                    }
                    $param = \@params;
                }
            }
            else {
                if (exists $module_param->{output}->{$param_names}) {
                    if (exists $module_param->{output}->{$param_names}->{media_type}) {
                        $param = [$module_param->{output}->{$param_names}];
                    } else {
                        warnf "module_param->{output}->{$param_names}->{media_type} field should be there" if (HALLOW_DEBUG);
                    }
                } else {
                    warnf "module_param->{output}->{$param_names} field should be there" if (HALLOW_DEBUG);
                }
            }
        } else {
            warnf "first argument must have param->{output}->{to} field" if (HALLOW_DEBUG);
        }
    } else {
        warnf "first argument must be HASH ref" if (HALLOW_DEBUG);
    }
    return $param;
}

sub _get_module_io_param_map {
    my ($self, $module_name) = @_;
    my $param = "";
    if (exists $self->{recipe_name}) {
        my $recipe_name = $self->{recipe_name};
        if ((defined $module_name) && ($module_name) && (exists $self->{config}->{$recipe_name}->{$module_name})) {
            my $module_param = $self->{config}->{$recipe_name}->{$module_name};
            my $i_params = $self->_get_module_input_params($module_param);
            my $o_params = $self->_get_module_output_params($module_param);
            $param = {
                'input' => $i_params,
                'output' => $o_params,
            };
        } else {
            warnf "Can't get module parameter from self->config->recipe_name->module_name" if (HALLOW_DEBUG);
        }
    } else {
        warnf "Can't get self->recipe_name" if (HALLOW_DEBUG);
    }
    return $param;
}

sub _get_module_io_target_map {
    my ($self, $io_param_map) = @_;
    my $target_map = "";
    if (ref $io_param_map eq "HASH") {
        my %tmp_target_map = ();
        my $is_same_num = 1;
        foreach my $key (keys %{$io_param_map}) { # key = input || output
            my $params = $io_param_map->{$key};
            if (ref $params eq "ARRAY") {
                my @parsed_params = ();
                foreach my $param (@{$params}) {
                    if (ref $param eq "HASH") {
                        if (exists $param->{media_type}) {
                            my $io_type = $param->{media_type};
                            if ($io_type eq "file") {
                                my $tmp_dir_path = Hallow::Data::Dump::get_dump_dir_path($param, $self->{base_dir_path}, $self->{current_dt});
                                my $tmp_file_path = Hallow::Data::Dump::get_dump_file_path($param, $tmp_dir_path, $self->{current_dt});
                                my $tmp = [$io_type, $tmp_file_path];
                                push @parsed_params, $tmp;
                            } elsif ($io_type eq "db") {
                                my $tmp = [$io_type, ""];
                                push @parsed_params, $tmp;
                            } else { warnf "Undefined media_type : $io_type, and you should set 'file' or 'db'" if (HALLOW_DEBUG); }
                        } else { warnf "io_param->{media_type} field should be exists" if (HALLOW_DEBUG); }
                    } else { warnf "param should be HASH ref" if (HALLOW_DEBUG); }
                }
                $tmp_target_map{$key} = \@parsed_params if (@parsed_params);
            } else { warnf "params should be ARRAY ref" if (HALLOW_DEBUG); }
            $is_same_num = 0 if (($#{$io_param_map->{$key}}) != ($#{$tmp_target_map{$key}}));
        }
        $target_map = \%tmp_target_map if (($is_same_num) && (keys %tmp_target_map));
    } else { warnf "io_param_map should be HASH ref" if (HALLOW_DEBUG); }
    return $target_map;
}

# module_name ごとの処理をaction()によって消化したい
# Hallowを継承した先のaction()を呼ぶので、いろんな機能に共通な処理だけ書く
sub start {
    my ($self, $module_name) = @_;
    my $is_extract = 0;
    # module_nameがなければ却下
    if (defined $module_name) {
        # module_nemeがあったらio_paramを確保する
        my $io_param_map = $self->_get_module_io_param_map($module_name);
        # io_targetをio_paramから取得する処理が頻発するので取得する
        # 後々、使わないで済むようにできたら消したい
        my $io_target_map = $self->_get_module_io_target_map($io_param_map);
        # ip_paramとio_targetが無いなら却下
        if (ref $io_param_map eq "HASH") {
            if (ref $io_target_map eq "HASH") {
                # io周りがあるならaction()でよく使う設定をselfに登録する
                # configで指定された機械学習のクライアントを登録する
                $self->{ml_client} = $self->get_ml_client($module_name);
                # action()を実行する
                # action()を呼ぶ。action()で消化した入力のentry数が返ってくる
                my $entry_count = $self->action($module_name, $io_param_map, $io_target_map);
                $is_extract += $entry_count;
                infof "processed entry number using action() : $entry_count" if (HALLOW_DEBUG);
            } else {
                warnf "io_target_map should be HASH ref" if (HALLOW_DEBUG);
            }
        } else { warnf "io_param_map should be HASH ref" if (HALLOW_DEBUG); }
    } else { warnf "module_name should be define" if (HALLOW_DEBUG); }
    # 入力を消化できたら1以上が返る
    return $is_extract;
}

sub action {
    my ($self, $module_name, $io_param_map, $io_target_map) = @_;
    my $config = $self->{config};

    #foreach my $io_source (@{$io_sources}) {
    #my $io_media_type = $io_source->[0];
    #if ((defined $io_media_type) && ($io_media_type eq "file")) {
    #my $min_log_size = 50; # 50 byte
    #my $io_file_path = $io_source->[1];
    #if ((-f $io_file_path) && (-s $io_file_path > $min_log_size)) {
    #infof "$io_file_path is extractable";
    return -1;
}

1;

__END__

=encoding utf-8

=head1 NAME

Hallow - It's new $module

=head1 SYNOPSIS

    use Hallow;

=head1 DESCRIPTION

Hallow is ...

=head1 LICENSE

Copyright (C) Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut
