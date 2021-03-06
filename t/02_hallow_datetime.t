use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow::DateTime;

subtest 'Test a generator of DateTime object' => sub {
    subtest 'Test get_dt()' => sub {
        my $unixtime = time();
        my $current_dt = Hallow::DateTime::get_dt();

        is(ref $current_dt, "DateTime", "test to get a DateTime object");

        my $current_epoch = $current_dt->epoch();
        my $diff_of_unixtime = $current_epoch - $unixtime;
        is($diff_of_unixtime, 0, "make cheke to get a DateTime object of current time");

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
         ], [2022, 10, 10, 10, 10, 10], "make ckeck to get a DateTime object of 20221010101010");

        is_deeply([
            $yyyymmddhhmm_dt->year(),
            $yyyymmddhhmm_dt->month(),
            $yyyymmddhhmm_dt->day(),
            $yyyymmddhhmm_dt->hour(),
            $yyyymmddhhmm_dt->minute(),
            $yyyymmddhhmm_dt->second(),
         ], [2022, 10, 10, 10, 10, 0], "make ckeck to get a DateTime object of 202210101010");

        is_deeply([
            $yyyymmddhhm_dt->year(),
            $yyyymmddhhm_dt->month(),
            $yyyymmddhhm_dt->day(),
            $yyyymmddhhm_dt->hour(),
            $yyyymmddhhm_dt->minute(),
            $yyyymmddhhm_dt->second(),
         ], [2022, 10, 10, 10, 10, 0], "make ckeck to get a DateTime object of 20221010101");

        is_deeply([
            $yyyymmddhh_dt->year(),
            $yyyymmddhh_dt->month(),
            $yyyymmddhh_dt->day(),
            $yyyymmddhh_dt->hour(),
            $yyyymmddhh_dt->minute(),
            $yyyymmddhh_dt->second(),
         ], [2022, 10, 10, 10, 0, 0], "make ckeck to get a DateTime object of 2022101010");

        is_deeply([
            $yyyymmdd_dt->year(),
            $yyyymmdd_dt->month(),
            $yyyymmdd_dt->day(),
            $yyyymmdd_dt->hour(),
            $yyyymmdd_dt->minute(),
            $yyyymmdd_dt->second(),
        ], [2022, 10, 10, 0, 0, 0], "make ckeck to get a DateTime object of 20221010");

        my $yyyymmdd_hhmmss = "2022-10-10 10:10:10";
        my $yyyymmddThhmmss = "2022-10-10T10:10:10";
        my $yyyymmdd_hhmm   = "2022-10-10 10:10";
        my $yyyymmddThhmm   = "2022-10-10T10:10";
        my $yyyymmdd_hhm    = "2022-10-10 10:1";
        my $yyyymmddThhm    = "2022-10-10T10:1";
        my $yyyymmdd_hh     = "2022-10-10 10";
        my $yyyymmddThh     = "2022-10-10T10";
        my $yyyymmdd_       = "2022-10-10";

        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhmmss), $yyyymmddhhmmss_dt, "make ckeck to get a DateTime object of 2022-10-10 10:10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhmmss), $yyyymmddhhmmss_dt, "make ckeck to get a DateTime object of 2022-10-10T10:10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhmm), $yyyymmddhhmm_dt, "make ckeck to get a DateTime object of 2022-10-10 10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhmm), $yyyymmddhhmm_dt, "make ckeck to get a DateTime object of 2022-10-10T10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhm), $yyyymmddhhm_dt, "make ckeck to get a DateTime object of 2022-10-10 10:1");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhm), $yyyymmddhhm_dt, "make ckeck to get a DateTime object of 2022-10-10T10:1");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hh), $yyyymmddhh_dt, "make ckeck to get a DateTime object of 2022-10-10 10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThh), $yyyymmddhh_dt, "make ckeck to get a DateTime object of 2022-10-10T10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_), $yyyymmdd_dt, "make ckeck to get a DateTime object of 2022-10-10");

        is(ref Hallow::DateTime::get_dt(""), "DateTime", "make ckeck to get a DateTime object for null character string");
        is(ref Hallow::DateTime::get_dt("highball"), "DateTime", "make ckeck to get a DateTime object for an unknown parameter");
    };
};

subtest 'Test to return the boundary of cyclical event' => sub {
    subtest 'Test get_seconds_based_on_cycle_type()' => sub {
        my $unixtime = time();
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "daily",}), 86400, "Make check a day is 86400 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "ymd",}), 86400, "Make check a day is 86400 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "yyyymmdd",}), 86400, "Make check a day is 86400 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "hourly",}), 3600, "Make check a hour is 3600 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "ymdh",}), 3600, "Make check a hour is 3600 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "yyyymmddhh",}), 3600, "Make check a hour is 3600 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "10min",}), 600, "Make check 10 minute is 600 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "yyyymmddhhm",}), 600, "Make check 10 minute is 600 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "minutely",}), 60, "Make check a minute is 60 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "ymdhm",}), 60, "Make check a minute is 60 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "yyyymmddhhmm",}), 60, "Make check a minute is 60 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "10sec",}), 10, "Make check a 10 seconds is 10 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "yyyymmddhhmms",}), 10, "Make check a hour is 10 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "secondly",}), 1, "Make check a second is 1 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "ymdhms",}), 1, "Make check a second is 1 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "yyyymmddhhmmss",}), 1, "Make check a second is 1 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "daily", "n_times" => 2}), 172800, "Make check a day is 172800 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "hourly", "n_times" => 2}), 7200, "Make check a hour is 7200 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "10min", "n_times" => 2}), 1200, "Make check 10 minute is 1200 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "minutely", "n_times" => 2}), 120, "Make check a minute is 120 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "10sec", "n_times" => 2}), 20, "Make check a 10 seconds is 20 seconds");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "secondly", "n_times" => 2}), 2, "Make check a second is 2 seconds");

        is (Hallow::DateTime::get_seconds_based_on_cycle_type(["array"]), -1, "Make check to get -1 as an error value");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"typo" => "",}), -1, "Make check to get -1 as an error value");
        is (Hallow::DateTime::get_seconds_based_on_cycle_type({"time_cycle_type" => "",}), -1, "Make check to get -1 as an error value");
    };

    subtest 'Test get_surplus_between_next_dt()' => sub {
        {
            my $ymdhms = "2022-10-10 10:10:10";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhms"}), 1, "Make check a surplus between 10:10:10 and 10:10:11");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhms", "n_times" => 2}),2, "Make check a surplus between 10:10:10 and 10:10:12");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms"}), 10, "Make check a surplus between 10:10:10 and 10:10:20");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms", "n_times" => 2}),10, "Make check a surplus between 10:10:10 and 10:10:20");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms", "n_times" => 3}),20, "Make check a surplus between 10:10:10 and 10:10:30");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhm"}), 50, "Make check a surplus between 10:10:10 and 10:11:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhm", "n_times" => 2}),110, "Make check a surplus between 10:10:10 and 10:12:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm"}), 590, "Make check a surplus between 10:10:10 and 10:20:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm", "n_times" => 2}),590, "Make check a surplus between 10:10:10 and 10:20:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm", "n_times" => 3}),1190, "Make check a surplus between 10:10:10 and 10:30:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhh"}), 2990, "Make check a surplus between 10:10:10 and 11:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhh", "n_times" => 2}),6590, "Make check a surplus between 10:10:10 and 12:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmdd"}), 49790, "Make check a surplus between 2022-10-10 10:10:10 and 2022-10-11 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmdd", "n_times" => 2}),49790, "Make check a surplus between 2022-10-10 10:10:10 and 2022-10-12 00:00:00");
        }

        {
            my $ymdhms = "2022-10-10 23:59:59";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhms"}), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhms", "n_times" => 2}),1, "Make check a surplus between 23:59:59 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms"}), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms", "n_times" => 2}),1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms", "n_times" => 3}),1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhm"}), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhm", "n_times" => 2}),1, "Make check a surplus between 23:59:59 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm"}), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm", "n_times" => 2}),1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm", "n_times" => 3}),1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhh"}), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhh", "n_times" => 2}),1, "Make check a surplus between 23:59:59 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmdd"}), 1, "Make check a surplus between 23:59:59 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmdd", "n_times" => 2}),1, "Make check a surplus between 23:59:59 and 00:00:00");
        }

        {
            my $ymdhms = "2022-10-10 00:00:00";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhms"}), 1, "Make check a surplus between 00:00:00 and 00:00:01");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhms", "n_times" => 2}),2, "Make check a surplus between 00:00:00 and 00:00:02");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms"}), 10, "Make check a surplus between 00:00:00 and 00:00:10");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms", "n_times" => 2}),20, "Make check a surplus between 00:00:00 and 00:00:20");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhmms", "n_times" => 3}),30, "Make check a surplus between 00:00:00 and 00:00:30");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhm"}), 60, "Make check a surplus between 00:00:00 and 00:01:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "ymdhm", "n_times" => 2}),120, "Make check a surplus between 00:00:00 and 00:02:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm"}), 600, "Make check a surplus between 00:00:00 and 00:10:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm", "n_times" => 2}),1200, "Make check a surplus between 00:00:00 and 00:20:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhhm", "n_times" => 3}),1800, "Make check a surplus between 00:00:00 and 00:30:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhh"}), 3600, "Make check a surplus between 00:00:00 and 01:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmddhh", "n_times" => 2}),7200, "Make check a surplus between 00:00:00 and 02:00:00");

            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmdd"}), 86400, "Make check a surplus between 00:00:00 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type"=> "yyyymmdd", "n_times" => 2}), 86400, "Make check a surplus between 00:00:00 and 00:00:00");
        }

        {
            my $ymdhms = "2022-10-10 00:00:00";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is (Hallow::DateTime::get_surplus_between_next_dt(), -1, "Make check to get -1 as an error value");
            is (Hallow::DateTime::get_surplus_between_next_dt($dt), -1, "Make check to get -1 as an error value");
            is (Hallow::DateTime::get_surplus_between_next_dt($dt, ["array"]), -1, "Make check to get -1 as an error value");
            is (Hallow::DateTime::get_surplus_between_next_dt($dt, {"typo" => "",}), -1, "Make check to get -1 as an error value");
            is (Hallow::DateTime::get_surplus_between_next_dt($dt, {"time_cycle_type" => "",}), -1, "Make check to get -1 as an error value");
        }
    };

    subtest 'Test get_surplus_between_prev_dt()' => sub {
        {
            my $ymdhms = "2022-10-10 10:30:30";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhms"}), 1, "Make check a surplus between 10:30:30 and 10:30:29");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhms", "n_times" => 2}), 2, "Make check a surplus between 10:30:30 and 10:30:28");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms"}),  10, "Make check a surplus between 10:30:30 and 10:30:20");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms", "n_times" => 2}), 10, "Make check a surplus between 10:30:30 and 10:30:20");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms", "n_times" => 3}), 30, "Make check a surplus between 10:30:30 and 10:30:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhm"}),  30, "Make check a surplus between 10:30:30 and 10:30:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhm", "n_times" => 2}), 30, "Make check a surplus between 10:30:30 and 10:30:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhm", "n_times" => 4}), 150, "Make check a surplus between 10:30:30 and 10:28:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm"}),  30, "Make check a surplus between 10:30:30 and 10:30:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm", "n_times" => 2}), 630, "Make check a surplus between 10:30:30 and 10:20:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm", "n_times" => 3}), 30, "Make check a surplus between 10:30:30 and 10:30:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhh"}),  1830, "Make check a surplus between 10:30:30 and 10:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhh", "n_times" => 2}), 1830, "Make check a surplus between 10:30:30 and 10:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhh", "n_times" => 3}), 5430, "Make check a surplus between 10:30:30 and 9:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmdd"}),  37830, "Make check a surplus between 2022-10-10 10:30:30 and 2022-10-10 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmdd", "n_times" => 2}), 37830, "Make check a surplus between 2022-10-10 10:30:30 and 2022-10-10 00:00:00");
        }

        {
            my $ymdhms = "2022-10-11 00:00:00";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhms"}),  1, "Make check a surplus between 00:00:00 and 23:59:59");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhms", "n_times" => 2}), 2, "Make check a surplus between 00:00:00 an 23:59:58");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms"}),  10, "Make check a surplus between 00:00:00 an 23:59:50");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms", "n_times" => 2}), 20, "Make check a surplus between 00:00:00 an 23:59:40");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms", "n_times" => 3}), 30, "Make check a surplus between 00:00:00 an 23:59:30");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhm"}), 60, "Make check a surplus between 00:00:00 an 23:59:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhm", "n_times" => 2}), 120, "Make check a surplus between 00:00:00 an 23:58:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm"}), 600, "Make check a surplus between 00:00:00 an 23:50:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm", "n_times" => 2}), 1200, "Make check a surplus between 00:00:00 an 23:40:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm", "n_times" => 3}), 1800, "Make check a surplus between 00:00:00 an 23:30:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhh"}), 3600, "Make check a surplus between 00:00:00 an 23:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhh", "n_times" => 2}), 7200, "Make check a surplus between 00:00:00 an 22:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmdd"}), 86400, "Make check a surplus between 2022-10-11 00:00:00 and 2022-10-10 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmdd", "n_times" => 2}), 86400, "Make check a surplus between 2022-10-11 00:00:00 and 2022-10-10 00:00:00");
        }

        {
            my $ymdhms = "2022-10-10 00:00:01";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhms"}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhms", "n_times" => 2}), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms"}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms", "n_times" => 2}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhmms", "n_times" => 3}), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhm"}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "ymdhm", "n_times" => 2}), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm"}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm", "n_times" => 2}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhhm", "n_times" => 3}), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhh"}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmddhh", "n_times" => 2}), 1, "Make check a surplus between 00:00:01 and 00:00:00");

            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmdd"}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
            is(Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "yyyymmdd", "n_times" => 2}), 1, "Make check a surplus between 00:00:01 and 00:00:00");
        }

        {
            my $ymdhms = "2022-10-10 00:00:00";
            my $dt = Hallow::DateTime::get_dt($ymdhms);
            my $type = "ymdhms";
            is (Hallow::DateTime::get_surplus_between_prev_dt(), -1, "Make check to get -1 as an error value");
            is (Hallow::DateTime::get_surplus_between_prev_dt($dt), -1, "Make check to get -1 as an error value");
            is (Hallow::DateTime::get_surplus_between_prev_dt($dt, ["array"]), -1, "Make check to get -1 as an error value");
            is (Hallow::DateTime::get_surplus_between_prev_dt($dt, {"typo" => "",}), -1, "Make check to get -1 as an error value");
            is (Hallow::DateTime::get_surplus_between_prev_dt($dt, {"time_cycle_type" => "",}), -1, "Make check to get -1 as an error value");
        }
    };

};

subtest 'Test to return a DateTime object of next cycle' => sub {
    subtest 'Test get_next_dt()' => sub {
        my $ymdhms = "2022-10-10 00:00:01";
        my $dt = Hallow::DateTime::get_dt($ymdhms);
        my $unixtime = time();
        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "daily",})->ymd(""), "20221011", "Make check a day after of 2022-10-10 00:00:01 is 2022-10-11 00:00:01");
        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "daily",})->hms(""), "000001", "Make check a day after of 2022-10-10 00:00:01 is 2022-10-11 00:00:01");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "daily", "is_cut_surplus" => 1}))->ymd(""), "20221011", "Make check a day after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-11 00:00:00");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "daily", "is_cut_surplus" => 1 }))->hms(""), "000000", "Make check a day after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-11 00:00:00");

        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "hourly",})->ymd(""), "20221010", "Make check an hour after of 2022-10-10 00:00:01 is 2022-10-10 01:00:01");
        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "hourly",})->hms(""), "010001", "Make check an hour after of 2022-10-10 00:00:01 is 2022-10-10 01:00:01");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "hourly", "is_cut_surplus" => 1}))->ymd(""), "20221010", "Make check an hour after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 01:00:00");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "hourly", "is_cut_surplus" => 1 }))->hms(""), "010000", "Make check an hour after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 01:00:00");

        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "minutely",})->ymd(""), "20221010", "Make check one minute after of 2022-10-10 00:00:01 is 2022-10-10 00:01:01");
        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "minutely",})->hms(""), "000101", "Make check one minute after of 2022-10-10 00:00:01 is 2022-10-10 00:01:01");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "minutely", "is_cut_surplus" => 1}))->ymd(""), "20221010", "Make check one minute after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 00:01:00");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "minutely", "is_cut_surplus" => 1 }))->hms(""), "000100", "Make check one minute after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 00:01:00");

        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "10min",})->ymd(""), "20221010", "Make check 10 minutes after of 2022-10-10 00:00:01 is 2022-10-10 00:10:01");
        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "10min",})->hms(""), "001001", "Make check 10 minutes after of 2022-10-10 00:00:01 is 2022-10-10 00:10:01");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "10min", "is_cut_surplus" => 1}))->ymd(""), "20221010", "Make check 10 minutes after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 00:10:00");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "10min", "is_cut_surplus" => 1 }))->hms(""), "001000", "Make check 10 minutes after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 00:10:00");

        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "secondly",})->ymd(""), "20221010", "Make check one second after of 2022-10-10 00:00:01 is 2022-10-10 00:00:02");
        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "secondly",})->hms(""), "000002", "Make check one second after of 2022-10-10 00:00:01 is 2022-10-10 00:00:02");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "secondly", "is_cut_surplus" => 1}))->ymd(""), "20221010", "Make check one second after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 00:00:02");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "secondly", "is_cut_surplus" => 1 }))->hms(""), "000002", "Make check one second after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 00:00:02");

        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "10sec",})->ymd(""), "20221010", "Make check 10 seconds after of 2022-10-10 00:00:01 is 2022-10-10 00:10:01");
        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "10sec",})->hms(""), "000011", "Make check 10 seconds after of 2022-10-10 00:00:01 is 2022-10-10 00:00:11");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "10sec", "is_cut_surplus" => 1}))->ymd(""), "20221010", "Make check 10 seconds after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 00:00:10");
        is ((Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "10sec", "is_cut_surplus" => 1 }))->hms(""), "000010", "Make check 10 seconds after of 2022-10-10 00:00:01 with cutting surplus is 2022-10-10 00:00:10");

        is (Hallow::DateTime::get_next_dt(), "", "Make check to get null character string as an error value");
        is (Hallow::DateTime::get_next_dt($dt), "", "Make check to get null character string as an error value");
        is (Hallow::DateTime::get_next_dt($dt, ["array"]), "", "Make check to get null character string as an error value");
        is (Hallow::DateTime::get_next_dt($dt, {"typo" => "",}), "", "Make check to get null character string as an error value");
        is (Hallow::DateTime::get_next_dt($dt, {"time_cycle_type" => "",}), "", "Make check to get null character string as an error value");
    };
};

subtest 'Test to return a DateTime object of prev cycle' => sub {
    subtest 'Test get_prev_dt()' => sub {
        my $ymdhms = "2022-10-09 23:59:59";
        my $dt = Hallow::DateTime::get_dt($ymdhms);
        my $unixtime = time();
        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "daily",})->ymd(""), "20221008", "Make check a day before of 2022-10-09 23:59:59 is 2022-10-08 23:59:59");
        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "daily",})->hms(""), "235959", "Make check a day before of 2022-10-09 23:59:59 is 2022-10-08 23:59:59");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "daily", "is_cut_surplus" => 1}))->ymd(""), "20221009", "Make check a day before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 00:00:00");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "daily", "is_cut_surplus" => 1 }))->hms(""), "000000", "Make check a day before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 00:00:00");

        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "hourly",})->ymd(""), "20221009", "Make check an hour before of 2022-10-09 23:59:59 is 2022-10-09 23:59:59");
        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "hourly",})->hms(""), "225959", "Make check an hour before of 2022-10-09 23:59:59 is 2022-10-09 22:59:59");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "hourly", "is_cut_surplus" => 1}))->ymd(""), "20221009", "Make check an hour before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:00:00");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "hourly", "is_cut_surplus" => 1 }))->hms(""), "230000", "Make check an hour before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:00:00");

        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "minutely",})->ymd(""), "20221009", "Make check one minute before of 2022-10-09 23:59:59 is 2022-10-09 23:58:59");
        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "minutely",})->hms(""), "235859", "Make check one minute before of 2022-10-09 23:59:59 is 2022-10-09 23:58:59");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "minutely", "is_cut_surplus" => 1}))->ymd(""), "20221009", "Make check one minute before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:59:00");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "minutely", "is_cut_surplus" => 1 }))->hms(""), "235900", "Make check one minute before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:59:00");

        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "10min",})->ymd(""), "20221009", "Make check 10 minutes before of 2022-10-09 23:59:59 is 2022-10-09 23:49:59");
        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "10min",})->hms(""), "234959", "Make check 10 minutes before of 2022-10-09 23:59:59 is 2022-10-09 23:49:59");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "10min", "is_cut_surplus" => 1}))->ymd(""), "20221009", "Make check 10 minutes before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:50:00");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "10min", "is_cut_surplus" => 1 }))->hms(""), "235000", "Make check 10 minutes before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:50:00");

        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "secondly",})->ymd(""), "20221009", "Make check one second before of 2022-10-09 23:59:59 is 2022-10-09 23:59:58");
        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "secondly",})->hms(""), "235958", "Make check one second before of 2022-10-09 23:59:59 is 2022-10-09 23:59:58");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "secondly", "is_cut_surplus" => 1}))->ymd(""), "20221009", "Make check one second before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:59:58");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "secondly", "is_cut_surplus" => 1 }))->hms(""), "235958", "Make check one second before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:59:58");

        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "10sec",})->ymd(""), "20221009", "Make check 10 seconds before of 2022-10-09 23:59:59 is 2022-10-09 23:59:49");
        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "10sec",})->hms(""), "235949", "Make check 10 seconds before of 2022-10-09 23:59:59 is 2022-10-09 23:59:49");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "10sec", "is_cut_surplus" => 1}))->ymd(""), "20221009", "Make check 10 seconds before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:59:50");
        is ((Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "10sec", "is_cut_surplus" => 1 }))->hms(""), "235950", "Make check 10 seconds before of 2022-10-09 23:59:59 with cutting surplus is 2022-10-09 23:59:50");

        is (Hallow::DateTime::get_prev_dt(), "", "Make check to get null character string as an error value");
        is (Hallow::DateTime::get_prev_dt($dt), "", "Make check to get null character string as an error value");
        is (Hallow::DateTime::get_prev_dt($dt, ["array"]), "", "Make check to get null character string as an error value");
        is (Hallow::DateTime::get_prev_dt($dt, {"typo" => "",}), "", "Make check to get null character string as an error value");
        is (Hallow::DateTime::get_prev_dt($dt, {"time_cycle_type" => "",}), "", "Make check to get null character string as an error value");
    };
};

subtest 'Test to return a time stamp string using DateTime object' => sub {
    my $ymdhms = "2022-10-09 23:59:59";
    my $dt = Hallow::DateTime::get_dt($ymdhms);

    subtest 'Test dt_to_ymdh()' => sub {
        is (Hallow::DateTime::dt_to_ymdh($dt), "2022100923", "Make check to get YYYYMMDDHH string using DateTime object");
        is (Hallow::DateTime::dt_to_ymdh(""), "", "Make check to get null character string as error message");
    };

    subtest 'Test dt_to_yyyymmddhhm()' => sub {
        is (Hallow::DateTime::dt_to_yyyymmddhhm($dt), "20221009235", "Make check to get YYYYMMDDHHM string using DateTime object");
        is (Hallow::DateTime::dt_to_yyyymmddhhm(""), "", "Make check to get null character string as error message");
    };

    subtest 'Test dt_to_ymdhm()' => sub {
        is (Hallow::DateTime::dt_to_ymdhm($dt), "202210092359", "Make check to get YYYYMMDDHHMM string using DateTime object");
        is (Hallow::DateTime::dt_to_ymdhm(""), "", "Make check to get null character string as error message");
    };

    subtest 'Test dt_to_yyyymmddhhmms()' => sub {
        is (Hallow::DateTime::dt_to_yyyymmddhhmms($dt), "2022100923595", "Make check to get YYYYMMDDHHMMS string using DateTime object");
        is (Hallow::DateTime::dt_to_yyyymmddhhmms(""), "", "Make check to get null character string as error message");
    };

    subtest 'Test dt_to_ymdhms()' => sub {
        is (Hallow::DateTime::dt_to_ymdhms($dt), "20221009235959", "Make check to get YYYYMMDDHHMMSS string using DateTime object");
        is (Hallow::DateTime::dt_to_ymdhms(""), "", "Make check to get null character string as error message");
    };
};

subtest 'Test to return int time stamp string using DateTime object and string type name' => sub {
    my $ymdhms = "2022-10-09 23:59:59";
    my $dt = Hallow::DateTime::get_dt($ymdhms);

    subtest 'Test get_int_time_stamp()' => sub {
        is (Hallow::DateTime::get_int_time_stamp($dt, {"time_cycle_type" => "ymd"}), "20221009", "Make check to get YYYYMMDD string using DateTime object");
        is (Hallow::DateTime::get_int_time_stamp($dt, {"time_cycle_type" => "ymdh"}), "2022100923", "Make check to get YYYYMMDDHH string using DateTime object");
        is (Hallow::DateTime::get_int_time_stamp($dt, {"time_cycle_type" => "yyyymmddhhm"}), "20221009235", "Make check to get YYYYMMDDHHM string using DateTime object");
        is (Hallow::DateTime::get_int_time_stamp($dt, {"time_cycle_type" => "ymdhm"}), "202210092359", "Make check to get YYYYMMDDHHMM string using DateTime object");
        is (Hallow::DateTime::get_int_time_stamp($dt, {"time_cycle_type" => "yyyymmddhhmms"}), "2022100923595", "Make check to get YYYYMMDDHHMMS string using DateTime object");
        is (Hallow::DateTime::get_int_time_stamp($dt, {"time_cycle_type" => "ymdhms"}), "20221009235959", "Make check to get YYYYMMDDHHMMSS string using DateTime object");
        is (Hallow::DateTime::get_int_time_stamp($dt), "", "Make check to get null character string as no type string error message");
        is (Hallow::DateTime::get_int_time_stamp($dt, ""), "", "Make check to get null character string as no type string error message");
        is (Hallow::DateTime::get_int_time_stamp("", {"time_cycle_type" => "ymd"}), "", "Make check to get null character string as no DateTime object error message");
        is (Hallow::DateTime::get_int_time_stamp({"time_cycle_type" => "ymd"}, $dt), "", "Make check to get null character string as no DateTime object error message");
    };
};

subtest 'Test to return a comparative result of the unixtime of two DateTime object' => sub {
    my $ymdhms1 = "2022-10-09 23:59:59";
    my $ymdhms2 = "2022-10-10 00:00:00";
    my $dt1 = Hallow::DateTime::get_dt($ymdhms1);
    my $dt2 = Hallow::DateTime::get_dt($ymdhms2);

    subtest 'Test is_first_dt_future()' => sub {
        is (Hallow::DateTime::is_first_dt_future($dt1, $dt2), -1, "Make check to get false value(-1) when second DateTime object is future");
        is (Hallow::DateTime::is_first_dt_future($dt1, $dt1), 0, "Make check to get false value(0) when both DateTime object is same");
        is (Hallow::DateTime::is_first_dt_future($dt2, $dt1), 1, "Make check to get true value(1) when second DateTime object is future");

        is (Hallow::DateTime::is_first_dt_future("", ""), "", "Make check to get null character string as undefined object error message");
        is (Hallow::DateTime::is_first_dt_future($dt1, ""), "", "Make check to get null character string as undefined object error message");
        is (Hallow::DateTime::is_first_dt_future("", $dt1), "", "Make check to get null character string as undefined object error message");
    };
};

subtest 'Test to return a comparative result of the unixtime of two DateTime object' => sub {
    my $ymdhms1 = "2022-10-09 23:59:59";
    my $ymdhms2 = "2022-10-10 00:00:00";
    my $dt1 = Hallow::DateTime::get_dt($ymdhms1);
    my $dt2 = Hallow::DateTime::get_dt($ymdhms2);
    my $param = {"delay_seconds" => 1};
    subtest 'Test add_delay_seconds_to_dt()' => sub {
        is_deeply(Hallow::DateTime::add_delay_seconds_to_dt($dt2, $param), $dt1, "Make check on 2022-10-10 00:00:00 - 1sec = 2022-10-09 23:59:59");
        is (Hallow::DateTime::add_delay_seconds_to_dt(""), "", "Make check to get null character string as undefined object error message");
        is (Hallow::DateTime::add_delay_seconds_to_dt($dt1), "", "Make check to get null character string as undefined parameter error message");
        is (Hallow::DateTime::add_delay_seconds_to_dt($dt1, ""), "", "Make check to get null character string as undefined parameter error message");

    };
};

done_testing;
