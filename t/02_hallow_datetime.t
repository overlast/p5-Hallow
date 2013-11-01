use strict;
use Test::More;

use File::Basename;
use File::Spec;

use Hallow::DateTime;

subtest 'Test a generator of DateTime object' => sub {
    subtest 'Test get_dt()' => sub {
        my $unixtime = time();
        my $current_dt = Hallow::DateTime::get_dt();
        is(ref $current_dt, "DateTime", "test to get DateTime object");

        my $current_epoch = $current_dt->epoch();
        my $diff_of_unixtime = $current_epoch - $unixtime;
        is($diff_of_unixtime, 0, "test to get DateTime object of current time");

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
         ], [2022, 10, 10, 10, 10, 10], "test to get DateTime object of 20221010101010");

        is_deeply([
            $yyyymmddhhmm_dt->year(),
            $yyyymmddhhmm_dt->month(),
            $yyyymmddhhmm_dt->day(),
            $yyyymmddhhmm_dt->hour(),
            $yyyymmddhhmm_dt->minute(),
            $yyyymmddhhmm_dt->second(),
         ], [2022, 10, 10, 10, 10, 0], "test to get DateTime object of 202210101010");

        is_deeply([
            $yyyymmddhhm_dt->year(),
            $yyyymmddhhm_dt->month(),
            $yyyymmddhhm_dt->day(),
            $yyyymmddhhm_dt->hour(),
            $yyyymmddhhm_dt->minute(),
            $yyyymmddhhm_dt->second(),
         ], [2022, 10, 10, 10, 10, 0], "test to get DateTime object of 20221010101");

        is_deeply([
            $yyyymmddhh_dt->year(),
            $yyyymmddhh_dt->month(),
            $yyyymmddhh_dt->day(),
            $yyyymmddhh_dt->hour(),
            $yyyymmddhh_dt->minute(),
            $yyyymmddhh_dt->second(),
         ], [2022, 10, 10, 10, 0, 0], "test to get DateTime object of 2022101010");

        is_deeply([
            $yyyymmdd_dt->year(),
            $yyyymmdd_dt->month(),
            $yyyymmdd_dt->day(),
            $yyyymmdd_dt->hour(),
            $yyyymmdd_dt->minute(),
            $yyyymmdd_dt->second(),
        ], [2022, 10, 10, 0, 0, 0], "test to get DateTime object of 20221010");

        my $yyyymmdd_hhmmss = "2022-10-10 10:10:10";
        my $yyyymmddThhmmss = "2022-10-10T10:10:10";
        my $yyyymmdd_hhmm   = "2022-10-10 10:10";
        my $yyyymmddThhmm   = "2022-10-10T10:10";
        my $yyyymmdd_hhm    = "2022-10-10 10:1";
        my $yyyymmddThhm    = "2022-10-10T10:1";
        my $yyyymmdd_hh     = "2022-10-10 10";
        my $yyyymmddThh     = "2022-10-10T10";
        my $yyyymmdd_       = "2022-10-10";

        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhmmss), $yyyymmddhhmmss_dt, "test to get DateTime object of 2022-10-10 10:10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhmmss), $yyyymmddhhmmss_dt, "test to get DateTime object of 2022-10-10T10:10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhmm), $yyyymmddhhmm_dt, "test to get DateTime object of 2022-10-10 10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhmm), $yyyymmddhhmm_dt, "test to get DateTime object of 2022-10-10T10:10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hhm), $yyyymmddhhm_dt, "test to get DateTime object of 2022-10-10 10:1");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThhm), $yyyymmddhhm_dt, "test to get DateTime object of 2022-10-10T10:1");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_hh), $yyyymmddhh_dt, "test to get DateTime object of 2022-10-10 10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmddThh), $yyyymmddhh_dt, "test to get DateTime object of 2022-10-10T10");
        is_deeply(Hallow::DateTime::get_dt($yyyymmdd_), $yyyymmdd_dt, "test to get DateTime object of 2022-10-10");
    };
};

done_testing;
