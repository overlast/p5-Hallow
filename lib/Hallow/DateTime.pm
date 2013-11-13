package Hallow::DateTime;

use 5.008005;
use strict;
use warnings;

our $VERSION = "0.0.0_01";

use utf8;
use autodie;

use DateTime;

use Hallow::Util;

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
    if ((ref $param eq "HASH") && (exists $param->{time_cycle_type}) && (ref $dt eq "DateTime")) {
        my $type = $param->{time_cycle_type};
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
    } else {
        if (!(ref $param eq "HASH")) {
            print "second argument must be HASH ref\n";
        }
        if ((ref $param eq "HASH") && !(exists $param->{time_cycle_type})) {
            print "second argument must have time_cycle_type field\n";
        }
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $surplus;
}

sub get_surplus_between_next_dt {
    my ($dt, $param) = @_;
    my $surplus = -1;
    if ((ref $param eq "HASH") && (exists $param->{time_cycle_type}) && (ref $dt eq "DateTime")) {
        my $type = $param->{time_cycle_type};
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
    } else {
        if (!(ref $param eq "HASH")) {
            print "second argument must be HASH ref\n";
        }
        if ((ref $param eq "HASH") && !(exists $param->{time_cycle_type})) {
            print "second argument must have time_cycle_type field\n";
        }
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $surplus;
}

sub get_seconds_based_on_cycle_type {
    my ($param) = @_;
    my $seconds = -1;
    if ((ref $param eq "HASH") && (exists $param->{time_cycle_type})) {
        my $type = $param->{time_cycle_type};
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
    } else {
        if (!(ref $param eq "HASH")) {
            print "first argument must be HASH ref\n";
        }
        if ((ref $param eq "HASH") && !(exists $param->{time_cycle_type})) {
            print "first argument must have time_cycle_type field\n";
        }
    }
    return $seconds;
}

sub get_prev_dt {
    my ($dt, $param) = @_;
    my $next_dt = "";
    if ((ref $param eq "HASH") && (exists $param->{time_cycle_type}) && (ref $dt eq "DateTime")) {
        $param->{n_times} = 1 unless ((exists $param->{n_times}) && ($param->{n_times} > 0));
        $param->{shift_seconds} = 0 unless ((exists $param->{shift_seconds}) && ($param->{shift_seconds} > 0));
        my $tmp_dt = $dt->clone();
        my $diff_of_right_time = 0;
        if ((exists $param->{is_cut_surplus}) && ($param->{is_cut_surplus})) {
            $diff_of_right_time = get_surplus_between_prev_dt($tmp_dt, $param);
        } else {
            $diff_of_right_time = get_seconds_based_on_cycle_type($param);
        }
        if ($diff_of_right_time >= 0) {
            $tmp_dt->subtract(seconds => $diff_of_right_time);
            $next_dt = $tmp_dt;
        }
    } else {
        if (!(ref $param eq "HASH")) {
            print "second argument must be HASH ref\n";
        }
        if ((ref $param eq "HASH") && !(exists $param->{time_cycle_type})) {
            print "second argument must have time_cycle_type field\n";
        }
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $next_dt;
}

sub get_next_dt {
    my ($dt, $param) = @_;
    my $next_dt = "";
    if ((ref $param eq "HASH") && (exists $param->{time_cycle_type}) && (ref $dt eq "DateTime")) {
        $param->{n_times} = 1 unless ((exists $param->{n_times}) && ($param->{n_times} > 0));
        $param->{shift_seconds} = 0 unless ((exists $param->{shift_seconds}) && ($param->{shift_seconds} > 0));
        my $tmp_dt = $dt->clone();
        my $diff_of_right_time = 0;
        if ((exists $param->{is_cut_surplus}) && ($param->{is_cut_surplus})) {
            $diff_of_right_time = get_surplus_between_next_dt($tmp_dt, $param);
        } else {
            $diff_of_right_time = get_seconds_based_on_cycle_type($param);
        }
        if ($diff_of_right_time >= 0) {
            $next_dt = $tmp_dt->add(seconds => $diff_of_right_time);
        }
    } else {
        if (!(ref $param eq "HASH")) {
            print "second argument must be HASH ref\n";
        }
        if ((ref $param eq "HASH") && !(exists $param->{time_cycle_type})) {
            print "second argument must have time_cycle_type field\n";
        }
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $next_dt;
}

sub dt_to_ymdh {
    my ($dt) = @_;
    my $str = "";
    if (ref $dt eq "DateTime") {
        my $ymd = $dt->ymd("");
        my $h = substr($dt->hms(""), 0, 2);
        $str = $ymd.$h;
    } else {
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $str;
}

sub dt_to_yyyymmddhhm {
    my ($dt) = @_;
    my $str = "";
    if (ref $dt eq "DateTime") {
        my $ymd = $dt->ymd("");
        my $hhm = substr($dt->hms(""), 0, 3);
        $str = $ymd.$hhm;
    } else {
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $str;
}

sub dt_to_ymdhm {
    my ($dt) = @_;
    my $str = "";
    if (ref $dt eq "DateTime") {
        my $ymd = $dt->ymd("");
        my $hm = substr($dt->hms(""), 0, 4);
        $str = $ymd.$hm;
    } else {
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $str;
}

sub dt_to_yyyymmddhhmms {
    my ($dt) = @_;
    my $str = "";
    if (ref $dt eq "DateTime") {
        my $ymd = $dt->ymd("");
        my $hhmms = substr($dt->hms(""), 0, 5);
        $str = $ymd.$hhmms;
    } else {
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $str;
}

sub dt_to_ymdhms {
    my ($dt) = @_;
    my $str = "";
    if (ref $dt eq "DateTime") {
        my $ymd = $dt->ymd("");
        my $hms = $dt->hms("");
        $str =  $ymd.$hms;
    } else {
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $str;
}

sub get_int_time_stamp {
    my ($dt, $param) = @_;
    my $stamp = "";
    if ((ref $param eq "HASH") && (exists $param->{time_cycle_type}) && (ref $dt eq "DateTime")) {
        my $type = $param->{time_cycle_type};
        if (($type eq "daily") || ($type eq "ymd") || ($type eq "yyyymmdd")) {
            $stamp = $dt->ymd("");
        } elsif (($type eq "hourly") || ($type eq "ymdh") || ($type eq "yyyymmddhh")) {
            $stamp = dt_to_ymdh($dt);
        } elsif (($type eq "10min") || ($type eq "yyyymmddhhm")) {
            $stamp = dt_to_yyyymmddhhm($dt);
        } elsif (($type eq "minutely") || ($type eq "ymdhm") || ($type eq "yyyymmddhhmm")) {
            $stamp = dt_to_ymdhm($dt);
        } elsif (($type eq "10sec") || ($type eq "yyyymmddhhmms")) {
            $stamp = dt_to_yyyymmddhhmms($dt);
        } elsif (($type eq "secondly") || ($type eq "ymdhms") || ($type eq "yyyymmddhhmmss")) {
            $stamp = dt_to_ymdhms($dt);
        }
    } else {
        if (!(ref $param eq "HASH")) {
            print "second argument must be HASH ref\n";
        }
        if ((ref $param eq "HASH") && !(exists $param->{time_cycle_type})) {
            print "second argument must have time_cycle_type field\n";
        }
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $stamp;
}

sub is_first_dt_future {
    my ($dt1, $dt2) = @_;
    my $is_future = "";
    if ((ref $dt1 eq "DateTime") && (ref $dt2 eq "DateTime")) {
        $is_future = -1;
        my $dt1_epoch = $dt1->epoch();
        my $dt2_epoch = $dt2->epoch();
        if ($dt1_epoch > $dt2_epoch) {
            $is_future = 1;
        } elsif ($dt1_epoch == $dt2_epoch) {
            $is_future = 0;
        }
    } else {
        if (!(ref $dt1 eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
        if (!(ref $dt1 eq "DateTime")) {
            print "second argument must be DateTime object\n";
        }
    }
    return $is_future;
}

sub add_delay_seconds_to_dt {
    my ($dt, $param) = @_;
    my $result_dt = "";
    if ((ref $param eq "HASH") && (exists $param->{delay_seconds}) && (ref $dt eq "DateTime")) {
        my $delay_seconds = $param->{delay_seconds};
        my $tmp_dt = $dt->clone();
        $tmp_dt->subtract(seconds => $delay_seconds) if ($delay_seconds > 0);
        $result_dt = $tmp_dt;
    } else {
        if (!(ref $param eq "HASH")) {
            print "second argument must be HASH ref\n";
        }
        if ((ref $param eq "HASH") && !(exists $param->{time_cycle_type})) {
            print "second argument must have delay_seconds field\n";
        }
        if (!(ref $dt eq "DateTime")) {
            print "first argument must be DateTime object\n";
        }
    }
    return $result_dt;
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
