package Hallow::DateTime;

use 5.008005;
use strict;
use warnings;

our $VERSION = "0.0.0_01";

use utf8;
use autodie;

use DateTime;


sub compare_dt_first_is_more {
    my ($self, $dt, $next_dt) = @_;
    my $is_crawlable = 0;
    my $dt_epoch = $dt->epoch();
    my $next_dt_epoch = $next_dt->epoch();
    if ($dt_epoch >= $next_dt_epoch) {
        $is_crawlable = 1;
   }
    return $is_crawlable;
}

sub get_ymd_stamp {
    my ($self, $named_conf, $dt) = @_;
    my $stamp = "";
    if (exists $named_conf->{file_split_type}) {
        my $type = $named_conf->{file_split_type};
        if (($type eq "daily") || ($type eq "ymd") || ($type eq "yyyymmdd")) {
            $stamp = $dt->ymd("");
        } elsif (($type eq "hourly") || ($type eq "ymdh") || ($type eq "yyyymmddhh")) {
            $stamp = $self->dt_to_ymdh($dt);
        } elsif (($type eq "minutely") || ($type eq "ymdhm") || ($type eq "yyyymmddhhmm")) {
            $stamp = $self->dt_to_ymdhm($dt);
        } elsif (($type eq "10min") || ($type eq "yyyymmddhhm")) {
            $stamp = $self->dt_to_yyyymmddhhm($dt);
        } elsif (($type eq "secondly") || ($type eq "ymdhms") || ($type eq "yyyymmddhhmmss")) {
            $stamp = $self->dt_to_ymdhms($dt);
        } elsif (($type eq "10sec") || ($type eq "yyyymmddhhmms")) {
            $stamp = $self->dt_to_yyyymmddhhmms($dt);
        }
    }
    unless ($stamp) {
        $stamp = $dt->ymd("");
    }
    return $stamp;
}

sub dt_to_ymdh {
    my ($self, $dt) = @_;
    my $ymd = $dt->ymd("");
    my $hour = $dt->hour();
    $hour = $self->num_to_num_string($hour, 2);
    return $ymd.$hour;
}

sub dt_to_ymdhm {
    my ($self, $dt) = @_;
    my $ymd = $dt->ymd("");
    my $hour = $dt->hour();
    my $minute = $dt->minute();
    $hour = $self->num_to_num_string($hour, 2);
    $minute = $self->num_to_num_string($minute, 2);
    return $ymd.$hour.$minute;
}

sub dt_to_ymdhms {
    my ($self, $dt) = @_;
    my $ymd = $dt->ymd("");
    my $hour = $dt->hour();
    my $minute = $dt->minute();
    my $second = $dt->second();
    $hour = $self->num_to_num_string($hour, 2);
    $minute = $self->num_to_num_string($minute, 2);
    $second = $self->num_to_num_string($second, 2);
    return $ymd.$hour.$minute.$second;
}

sub dt_to_yyyymmddhhm {
    my ($self, $dt) = @_;
    my $ymd = $dt->ymd("");
    my $hour = $dt->hour();
    $hour = $self->num_to_num_string($hour, 2);
    my $minute = $dt->minute();
    $minute = int($minute / 10);
    return $ymd.$hour.$minute;
}

sub dt_to_yyyymmddhhmms {
    my ($self, $dt) = @_;
    my $ymd = $dt->ymd("");
    my $hour = $dt->hour();
    my $minute = $dt->minute();
    $hour = $self->num_to_num_string($hour, 2);
    $minute = $self->num_to_num_string($minute, 2);
    my $second = $dt->second();
    $second = int($second / 10);
    return $ymd.$hour.$minute.$second;
}

sub num_to_num_string {
    my ($self, $num, $digit) = @_;
    my $length = 1;
    my $tmp = $num;
    while (int($tmp / 10) > 0) {
        $length++;
        $tmp = int($tmp / 10);
    }
    my $diff = $digit - $length;
    while ($diff > 0) {
        $num = "0".$num;
        $diff--;
    }
    return $num;
}

sub get_dt {
    my ($datetime_str) = @_;
    my ($year, $month, $day, $hour, $minute, $second) = (0, 0, 0, 0, 0, 0);
    if (defined $datetime_str) {
        if ($datetime_str =~ m|^([0-9]{4})-?([0-9]{2})-?([0-9]{2})[ T]?([0-9]{2}):?([0-9]{2}):?([0-9]{2})$|) {
            ($year, $month, $day, $hour, $minute, $second) = ($1, $2, $3, $4, $5, $6);
        } elsif ($datetime_str =~ m|^([0-9]{4})-?([0-9]{2})-?([0-9]{2})[ T]?([0-9]{2}):?([0-9]{2})$|) {
            ($year, $month, $day, $hour, $minute) = ($1, $2, $3, $4, $5);
        } elsif ($datetime_str =~ m|^([0-9]{4})-?([0-9]{2})-?([0-9]{2})[ T]?([0-9]{2}):?([0-9]{1})$|) {
            ($year, $month, $day, $hour, $minute) = ($1, $2, $3, $4, $5);
            $minute *= 10;
        }
        elsif ($datetime_str =~ m|^([0-9]{4})-?([0-9]{2})-?([0-9]{2})[ T]?([0-9]{2})$|) {
            ($year, $month, $day, $hour) = ($1, $2, $3, $4);
        }
        elsif ($datetime_str =~ m|^([0-9]{4})-?([0-9]{2})-?([0-9]{2})$|) {
            ($year, $month, $day) = ($1, $2, $3);
        }
    }
    my $dt = "";
    if (($year > 0) && ($month > 0) && ($day > 0)) {
        $dt = DateTime->new( time_zone => 'Asia/Tokyo', 'year' => $year, 'month' => $month, 'day' => $day, 'hour' => $hour, 'minute' => $minute, 'second' => $second);
    } else {
        $dt = DateTime->now( time_zone => 'Asia/Tokyo' );
    }
    return $dt;
}

sub get_surplus_between_prev_dt {
    my ($dt, $param) = @_;
    my $surplus = -1;
    if ((exists $param->{type}) && (ref $dt eq "DateTime")) {
        my $type = $param->{type};
        my $n_times = 1;
        $n_times = $param->{n_times} if ((exists $param->{n_times}) && ($param->{n_times} > 1));

        my $hour = $dt->hour();
        my $minute = $dt->minute();
        my $second = $dt->second();
        if (($type eq "daily") || ($type eq "ymd") || ($type eq "yyyymmdd")) {
            $surplus = (($hour * 3600) + ($minute * 60) + $second) % 86400;
            $surplus = 86400 unless ($surplus);
        } elsif (($type eq "hourly") || ($type eq "ymdh") || ($type eq "yyyymmddhh")) {
            $surplus = (($hour * 3600) + ($minute * 60) + $second) % (3600 * $n_times);
            $surplus = 3600 * $n_times unless ($surplus);
        } elsif (($type eq "minutely") || ($type eq "ymdhm") || ($type eq "yyyymmddhhmm")) {
            $surplus = ($minute * 60 + $second) % (60 * $n_times);
            $surplus = 60 * $n_times unless ($surplus);
        } elsif (($type eq "10min") || ($type eq "yyyymmddhhm")) {
            $surplus = ($minute * 60 + $second) % (600 * $n_times);
            $surplus = 600 * $n_times unless ($surplus);
        } elsif (($type eq "secondly") || ($type eq "ymdhms") || ($type eq "yyyymmddhhmmss")) {
            $surplus = $second % (1 * $n_times);
            $surplus = 1 * $n_times unless ($surplus);
        } elsif (($type eq "10sec") || ($type eq "yyyymmddhhmms")) {
            $surplus = $second % (10 * $n_times);
            $surplus = 10 * $n_times unless ($surplus);
        }
    }
    return $surplus;
}

sub get_surplus_between_next_dt {
    my ($dt, $param) = @_;
    my $surplus = -1;
    if ((exists $param->{type}) && (ref $dt eq "DateTime")) {
        my $type = $param->{type};
        my $n_times = 1;
        $n_times = $param->{n_times} if ((exists $param->{n_times}) && ($param->{n_times} > 1));

        my $hour = $dt->hour();
        my $minute = $dt->minute();
        my $second = $dt->second();
        if (($type eq "daily") || ($type eq "ymd") || ($type eq "yyyymmdd")) {
            $surplus = 86400 - (($hour * 3600) + ($minute * 60) + $second);
        } elsif (($type eq "hourly") || ($type eq "ymdh") || ($type eq "yyyymmddhh")) {
            $surplus = (3600 * $n_times) - ((($hour * 3600) + ($minute * 60) + $second) % (3600 * $n_times));
        } elsif (($type eq "minutely") || ($type eq "ymdhm") || ($type eq "yyyymmddhhmm")) {
            $surplus = (60 * $n_times) - ((($minute * 60) + $second) % (60 * $n_times));
        } elsif (($type eq "10min") || ($type eq "yyyymmddhhm")) {
            $surplus = (600 * $n_times) - ((($minute * 60) + $second) % (600 * $n_times));
        } elsif (($type eq "secondly") || ($type eq "ymdhms") || ($type eq "yyyymmddhhmmss")) {
            $surplus = (1 * $n_times) - ($second % (1 * $n_times));
        } elsif (($type eq "10sec") || ($type eq "yyyymmddhhmms")) {
            $surplus = (10 * $n_times) - ($second % (10 * $n_times));
        }
    }
    return $surplus;
}

sub get_seconds_based_on_cycle_type {
    my ($param) = @_;
    my $seconds = -1;
    if (exists $param->{type}) {
        my $type = $param->{type};
        my $n_times = 1;
        $n_times = $param->{n_times} if ((exists $param->{n_times}) && ($param->{n_times} > 1));
        if (($type eq "daily") || ($type eq "ymd") || ($type eq "yyyymmdd")) {
            $seconds = 86400 * $n_times;
        } elsif (($type eq "hourly") || ($type eq "ymdh") || ($type eq "yyyymmddhh")) {
            $seconds = 3600 * $n_times;
        } elsif (($type eq "minutely") || ($type eq "ymdhm") || ($type eq "yyyymmddhhmm")) {
            $seconds = 60 * $n_times;
        } elsif (($type eq "10min") || ($type eq "yyyymmddhhm")) {
            $seconds = 600 * $n_times;
        } elsif (($type eq "secondly") || ($type eq "ymdhms") || ($type eq "yyyymmddhhmmss")) {
            $seconds = 1 * $n_times;
        } elsif (($type eq "10sec") || ($type eq "yyyymmddhhmms")) {
            $seconds = 10 * $n_times;
        }
    }
    return $seconds;
}

sub get_prev_dt {
    my ($dt, $param) = @_;
    $param->{n_times} = 1 unless ((exists $param->{n_times}) && ($param->{n_times} > 0));
    $param->{shift_seconds} = 0 unless ((exists $param->{shift_seconds}) && ($param->{shift_seconds} > 0));
    my $next_dt = "";
    if (exists $param->{type}) {
        $next_dt = $dt->clone();
        my $diff_of_right_time = 0;
        if ((exists $param->{is_cut_surplus}) && ($param->{is_cut_surplus})) {
            $diff_of_right_time = get_surplus_of_prev_dt($next_dt, $param);
        } else {
            $diff_of_right_time = get_seconds_based_on_cycle_type($param);
        }
        $next_dt->subtract(seconds => $diff_of_right_time);
    }
    return $next_dt;
}

sub get_next_dt {
    my ($dt, $param) = @_;
    $param->{n_times} = 1 unless ((exists $param->{n_times}) && ($param->{n_times} > 0));
    $param->{shift_seconds} = 0 unless ((exists $param->{shift_seconds}) && ($param->{shift_seconds} > 0));
    my $next_dt = "";
    if (exists $param->{type}) {
        $next_dt = $dt->clone();
        my $diff_of_right_time = 0;
        if ((exists $param->{is_cut_surplus}) && ($param->{is_cut_surplus})) {
            $diff_of_right_time = get_surplus_of_next_dt($next_dt, $param);
        } else {
            $diff_of_right_time = get_seconds_based_on_cycle_type($param);
        }
        $next_dt->add(seconds => $diff_of_right_time);
    }
    return $next_dt;
}

1;

__END__

=encoding utf-8

=head1 NAME

Hallow::DateTime - It's new $module

=head1 SYNOPSIS

    use Hallow::DateTime;

=head1 DESCRIPTION

Hallow::DateTime is ...

=head1 LICENSE

Copyright (C) Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut
