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

use Jubatus;

use Hallow::Util;
use Hallow::DateTime;
use Hallow::Data::Handle;
use Hallow::Data::Dump;

sub new {
    my ($class, $param) = @_;
    my $hash = {};
    if (defined $param) {
        if (ref $param eq "HASH") {
            $hash = $param;
        } else {
            warnf "First argument should be define as HASH ref" if (HALLOW_DEBUG);
        }
    }
    $hash->{base_dir_path} = Hallow::Util::get_base_dir_path();
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
                warn "Can't get DateTime object from get_prev_dt()" if (HALLOW_DEBUG);
            }
        } else {
            warn "Can't get DateTime object from get_dt()" if (HALLOW_DEBUG);
        }
    } else {
        warn "Can't get parameters to initialize DateTime object" if (HALLOW_DEBUG);
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
        infof ("boot sequence() ...");
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
                            infof "Exit sequence() because time_stamp > module_param->{end_ymdhms}";
                            $is_last_of_sequence = 1; last;
                        }
                        my $next_dt = Hellow::DateTime::get_next_dt($next_dt_map{$module_name}, $module_param);
                        if (ref $next_dt eq "DateTime") {
                            $next_dt_map{$module_name} = $next_dt;
                        } else {
                            warn "Can't get DateTime object by get_next_dt()" if (HALLOW_DEBUG);
                            $is_last_of_sequence = 1; last;
                        }
                        infof ("start() to process...");
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

sub _get_module_input_param {
    my ($self, $module_param) = @_;
    my $param = "";
    if (ref $module_param eq "HASH") {
        if (exists $module_param->{input}) {
            $param = $module_param->{input};
        } else {
            warnf "first argument must have input field" if (HALLOW_DEBUG);
        }
    } else {
        warnf "first argument must be HASH ref" if (HALLOW_DEBUG);
    }
    return $param;
}

sub _get_module_output_param {
    my ($self, $module_param) = @_;
    my $param = "";
    if (ref $module_param eq "HASH") {
        if (exists $module_param->{output}) {
            $param = $module_param->{output};
        } else {
            warnf "first argument must have output field" if (HALLOW_DEBUG);
        }
    } else {
        warnf "first argument must be HASH ref" if (HALLOW_DEBUG);
    }
    return $param;
}

sub _get_module_input_source {
    my ($self, $param) = @_;
    my @sources = ();
    my $input_param = $self->{config}->{input};
    if ((exists $input_param->{from}) && (ref $input_param->{from} eq "ARRAY")) {
        foreach my $from (@{$input_param->{from}}) {
            if (exists $input_param->{$from}) {
                my $from_param = $input_param->{$from};
                if (ref $from_param eq "HASH") {
                    my $from_type = $from_param->{type};
                    if ($from_type eq "dump_file") {
                        my $tmp_dir_path = Hallow::Data::Dump::get_dump_dir_path($from_param, $self->{base_dir_path}, $self->{dt});
                        my $tmp_file_path = Hallow::Data::Dump::get_dump_file_path($from_param, $tmp_dir_path, $self->{dt});
                        if (-f $tmp_file_path) {
                            my $tmp = [$from_type, $tmp_file_path];
                            push @sources, $tmp;
                        } else { warnf "tmp_file_path should be there" if (HALLOW_DEBUG); }
                    } elsif ($from_type eq "db") {
                    } else { warnf "Undefined from_type : $from_type" if (HALLOW_DEBUG); }
                } else { warnf "from_param should be HASH ref" if (HALLOW_DEBUG); }
            } else { warnf "input_param->{$from} should be defined" if (HALLOW_DEBUG); }
        }
    } else { warnf "input_param->{from} should be ARRAY ref" if (HALLOW_DEBUG); }
    return \@sources;
}

sub start {
    my ($self, $module_name) = @_;
    my $is_extract = 0;
    my $module_param = $self->_get_module_param($module_name);
    my $input_source = $self->get_module_input_source($module_param);
    if (ref $input_source eq "ARRAY") {
        foreach my $input (@{$input_source}) {
            my $input_type = $input_source->[0];
            if ((defined $input_type) && ($input_type eq "dump_file")) {
                my $min_log_size = 50; # 50 byte
                my $input_file_path = $input_source->[1];
                if ((-f $input_file_path) && (-s $input_file_path > $min_log_size)) {
                    infof "$input_file_path is extractable";
                    $is_extract++;
                    my $estimate_count = $self->action($self->{config}, $module_name, $input_file_path);
                    infof $estimate_count;
                } elsif (-f $input_file_path) {
                    infof "$input_file_path hasn't any entry";
                } else {
                    warnf "$input_file_path isn't extractable" if (HALLOW_DEBUG);
                }
            } else { warnf "input_type should be defined" if (HALLOW_DEBUG); }
        }
    } else { warnf "input_source should be ARRAY ref" if (HALLOW_DEBUG); }
    return $is_extract;
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
