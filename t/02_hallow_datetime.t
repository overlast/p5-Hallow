use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow::DateTime;

subtest 'Test a generator of DateTime object' => sub { subtest 'Test
    get_dt()' => sub { my $unixtime = time(); my $current_dt =
    Hallow::DateTime::get_dt(); is(ref $current_dt, "DateTime", "test
    to get DateTime object");

        my $current_epoch = $current_dt->epoch();
        my $diff_of_unixtime = $current_epoch - $unixtime;
        is($diff_of_unixtime, 0, "make cheke to get DateTime object of current time");

        my $yyyymmddhhmmss = "20221010101010";
        my $yyyymmddhhmm   = "202210101010";
        my $yyyymmddhhm    = "20221010101";
        my $yyyymmddhh     = "2022101010";
        my $yyyymmdd       = "20221010";

        my $yyyymmddhhmmss_dt = Hallow::DateTime::get_dt($yyyymmddhhmmss);
        my $yyyymmddhhmm_dt   = Hallow::DateTime::get_dt($yyyymmddhhmm);
        my $yyyymmddhhm_dt    = Hallow::DateTime::get_dt($yyyymmddhhm);
        my $yyyymmddhh_dt     = Hallow::DateTime::get_dt($yyyymmddhh);
        my $yyyymmdd_dt       = Hallow::DateTime::get_dt($yyyymmdd);

        is_deeply([
            $yyyymmddhhmmss_dt->year(),
            $yyyymmddhhmmss_dt->month(),
            $yyyymmddhhmmss_dt->day(),
            $yyyymmddhhmmss_dt->hour(),
            $yyyymmddhhmmss_dt->minute(),
            $yyyymmddhhmmss_dt->second(),
         ], [2022, 10, 10, 10, 10, 10], "make ckeck to get DateTime object of 20221010101010");

        is_deeply([
            $yyyymmddhhmm_dt->year(),
            $yyyymmddhhmm_dt->month(),
            $yyyymmddhhmm_dt->day(),
            $yyyymmddhhmm_dt->hour(),
            $yyyymmddhhmm_dt->minute(),
            $yyyymmddhhmm_dt->second(),
         ], [2022, 10, 10, 10, 10, 0], "make ckeck to get DateTime object of 202210101010");

        is_deeply([
            $yyyymmddhhm_dt->year(),
            $yyyymmddhhm_dt->month(),
            $yyyymmddhhm_dt->day(),
            $yyyymmddhhm_dt->hour(),
            $yyyymmddhhm_dt->minute(),
            $yyyymmddhhm_dt->second(),
         ], [2022, 10, 10, 10, 10, 0], "make ckeck to get DateTime object of 20221010101");

        is_deeply([
            $yyyymmddhh_dt->year(),
            $yyyymmddhh_dt->month(),
            $yyyymmddhh_dt->day(),
            $yyyymmddhh_dt->hour(),
            $yyyymmddhh_dt->minute(),
            $yyyymmddhh_dt->second(),
         ], [2022, 10, 10, 10, 0, 0], "make ckeck to get DateTime object of 2022101010");

        is_deeply([
            $yyyymmdd_dt->year(),
            $yyyymmdd_dt->month(),
            $yyyymmdd_dt->day(),
            $yyyymmdd_dt->hour(),
            $yyyymmdd_dt->minute(),
            $yyyymmdd_dt->second(),
        ], [2022, 10, 10, 0, 0, 0], "make ckeck to get DateTime object of 20221010");

        my $yyyymmdd_hhmmss = "2022-10-10 10:10:10";
        my $yyyymmddThhmmss = "2022-10-10T10:10:10";
        my $yyyymmdd_hhmm   = "2022-10-10 10:10";
        my $yyyymmddThhmm   = "2022-10-10T10:10";
        my $yyyymmdd_hhm    = "2022-10-10 10:1";
        my $yyyymmddThhm    = "2022-10-10T10:1";
        my $yyyymmdd_hh     = "2022-10-10 10";
        my $yyyymmddThh     = "2022-10-10T10";
        my $yyyymmdd_       = "2022-10-10";

        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhmmss), $yyyymmddhhmmss_dt, "make ckeck to get DateTime object of 2022-10-10 10:10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhmmss), $yyyymmddhhmmss_dt, "make ckeck to get DateTime object of 2022-10-10T10:10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhmm), $yyyymmddhhmm_dt, "make ckeck to get DateTime object of 2022-10-10 10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhmm), $yyyymmddhhmm_dt, "make ckeck to get DateTime object of 2022-10-10T10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhm), $yyyymmddhhm_dt, "make ckeck to get DateTime object of 2022-10-10 10:1");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhm), $yyyymmddhhm_dt, "make ckeck to get DateTime object of 2022-10-10T10:1");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hh), $yyyymmddhh_dt, "make ckeck to get DateTime object of 2022-10-10 10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThh), $yyyymmddhh_dt, "make ckeck to get DateTime object of 2022-10-10T10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_), $yyyymmdd_dt, "make ckeck to get DateTime object of 2022-10-10");
    };
};

subtest 'Test to return the boundary of cyclical event' => sub {
    subtest 'Test get_seconds_based_on_cycle_type()' => sub {
        my $unixtime = time();
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("daily"), 86400, "Make check a day is 86400 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("ymd"), 86400, "Make check a day is 86400 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("yyyymmdd"), 86400, "Make check a day is 86400 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type("hourly"), 3600, "Make check a hour is 3600 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("ymdh"), 3600, "Make check a hour is 3600 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("yyyymmddhh"), 3600, "Make check a hour is 3600 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type("10min"), 600, "Make check 10 minute is 600 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("yyyymmddhhm"), 600, "Make check 10 minute is 600 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type("minutely"), 60, "Make check a minute is 60 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("ymdhm"), 60, "Make check a minute is 60 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("yyyymmddhhmm"), 60, "Make check a minute is 60 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type("10sec"), 10, "Make check a 10 seconds is 10 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("yyyymmddhhmms"), 10, "Make check a hour is 10 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type("secondly"), 1, "Make check a second is 1 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("ymdhms"), 1, "Make check a second is 1 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("yyyymmddhhmmss"), 1, "Make check a second is 1 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type("daily", 2), 172800, "Make check a day is 172800 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("hourly", 2), 7200, "Make check a hour is 7200 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("10min", 2), 1200, "Make check 10 minute is 1200 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("minutely", 2), 120, "Make check a minute is 120 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("10sec", 2), 20, "Make check a 10 seconds is 20 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type("secondly", 2), 2, "Make check a second is 2 seconds");
    };

    subtest 'Test get_surplus_between_next_dt()' => sub {
        {
            my $ymdhms = "2022-10-10 10:10:10";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhms", $dt), 1, "Make check a surplus between 10:10:10 and 10:10:11");
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhms", $dt, 2), 2, "Make check a surplus between 10:10:10 and 10:10:12");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt), 10, "Make check a surplus between 10:10:10 and 10:10:20");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt, 2), 10, "Make check a surplus between 10:10:10 and 10:10:20");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt, 3), 20, "Make check a surplus between 10:10:10 and 10:10:30");

            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhm", $dt), 50, "Make check a surplus between 10:10:10 and 10:11:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhm", $dt, 2), 110, "Make check a surplus between 10:10:10 and 10:12:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt), 590, "Make check a surplus between 10:10:10 and 10:20:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt, 2), 590, "Make check a surplus between 10:10:10 and 10:20:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt, 3), 1190, "Make check a surplus between 10:10:10 and 10:30:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhh", $dt), 2990, "Make check a surplus between 10:10:10 and 11:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhh", $dt, 2), 6590, "Make check a surplus between 10:10:10 and 12:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmdd", $dt), 49790, "Make check a surplus between 2022-10-10 10:10:10 and 2022-10-11 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmdd", $dt, 2), 49790, "Make check a surplus between 2022-10-10 10:10:10 and 2022-10-12 00:00:00");
        }

        {
            my $ymdhms = "2022-10-10 23:59:59";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhms", $dt), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhms", $dt, 2), 1, "Make check a surplus between 23:59:59 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt, 2), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt, 3), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhm", $dt), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhm", $dt, 2), 1, "Make check a surplus between 23:59:59 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt, 2), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt, 3), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhh", $dt), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhh", $dt, 2), 1, "Make check a surplus between 23:59:59 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmdd", $dt), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmdd", $dt, 2), 1, "Make check a surplus between 23:59:59 and 00:00:00");
        }

        {
            my $ymdhms = "2022-10-10 00:00:00";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhms", $dt), 1, "Make check a surplus between 00:00:00 and 00:00:01");
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhms", $dt, 2), 2, "Make check a surplus between 00:00:00 and 00:00:02");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt), 10, "Make check a surplus between 00:00:00 and 00:00:10");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt, 2), 20, "Make check a surplus between 00:00:00 and 00:00:20");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhmms", $dt, 3), 30, "Make check a surplus between 00:00:00 and 00:00:30");

            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhm", $dt), 60, "Make check a surplus between 00:00:00 and 00:01:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("ymdhm", $dt, 2), 120, "Make check a surplus between 00:00:00 and 00:02:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt), 600, "Make check a surplus between 00:00:00 and 00:10:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt, 2), 1200, "Make check a surplus between 00:00:00 and 00:20:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhhm", $dt, 3), 1800, "Make check a surplus between 00:00:00 and 00:30:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhh", $dt), 3600, "Make check a surplus between 00:00:00 and 01:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmddhh", $dt, 2), 7200, "Make check a surplus between 00:00:00 and 02:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmdd", $dt), 86400, "Make check a surplus between 00:00:00 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt("yyyymmdd", $dt, 2), 86400, "Make check a surplus between 00:00:00 and 00:00:00");
        }
    };

    subtest 'Test get_surplus_between_prev_dt()' => sub {
        {
            my $ymdhms = "2022-10-10 10:30:30";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhms", $dt), 1, "Make check a surplus between 10:30:30 and 10:30:29");
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhms", $dt, 2), 2, "Make check a surplus between 10:30:30 and 10:30:28");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt), 10, "Make check a surplus between 10:30:30 and 10:30:20");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt, 2), 10, "Make check a surplus between 10:30:30 and 10:30:20");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt, 3), 30, "Make check a surplus between 10:30:30 and 10:30:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhm", $dt), 30, "Make check a surplus between 10:30:30 and 10:30:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhm", $dt, 2), 30, "Make check a surplus between 10:30:30 and 10:30:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhm", $dt, 4), 150, "Make check a surplus between 10:30:30 and 10:28:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt), 30, "Make check a surplus between 10:30:30 and 10:30:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt, 2), 630, "Make check a surplus between 10:30:30 and 10:20:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt, 3), 30, "Make check a surplus between 10:30:30 and 10:30:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhh", $dt), 1830, "Make check a surplus between 10:30:30 and 10:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhh", $dt, 2), 1830, "Make check a surplus between 10:30:30 and 10:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhh", $dt, 3), 5430, "Make check a surplus between 10:30:30 and 9:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmdd", $dt), 37830, "Make check a surplus between 2022-10-10 10:30:30 and 2022-10-10 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmdd", $dt, 2), 37830, "Make check a surplus between 2022-10-10 10:30:30 and 2022-10-10 00:00:00");
        }

        {
            my $ymdhms = "2022-10-11 00:00:00";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhms", $dt), 1, "Make check a surplus between 00:00:00 and 23:59:59");
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhms", $dt, 2), 2, "Make check a surplus between 00:00:00 an 23:59:58");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt), 10, "Make check a surplus between 00:00:00 an 23:59:50");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt, 2), 20, "Make check a surplus between 00:00:00 an 23:59:40");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt, 3), 30, "Make check a surplus between 00:00:00 an 23:59:30");

            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhm", $dt), 60, "Make check a surplus between 00:00:00 an 23:59:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhm", $dt, 2), 120, "Make check a surplus between 00:00:00 an 23:58:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt), 600, "Make check a surplus between 00:00:00 an 23:50:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt, 2), 1200, "Make check a surplus between 00:00:00 an 23:40:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt, 3), 1800, "Make check a surplus between 00:00:00 an 23:30:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhh", $dt), 3600, "Make check a surplus between 00:00:00 an 23:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhh", $dt, 2), 7200, "Make check a surplus between 00:00:00 an 22:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmdd", $dt), 86400, "Make check a surplus between 2022-10-11 00:00:00 and 2022-10-10 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmdd", $dt, 2), 86400, "Make check a surplus between 2022-10-11 00:00:00 and 2022-10-10 00:00:00");
        }

        {
            my $ymdhms = "2022-10-10 00:00:01";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhms", $dt), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhms", $dt, 2), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt, 2), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhmms", $dt, 3), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhm", $dt), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("ymdhm", $dt, 2), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt, 2), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhhm", $dt, 3), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhh", $dt), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmddhh", $dt, 2), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmdd", $dt), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt("yyyymmdd", $dt, 2), 1, "Make check a surplus between 00:00:01 and 00:00:00");
        }
    };

};





done_testing;
