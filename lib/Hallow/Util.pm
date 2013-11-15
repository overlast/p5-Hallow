package Hallow::Util;

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

use Config::JSON;
use File::Basename;
use File::Spec;
use FindBin;
use Scalar::Util;

sub complete_file_path {
    my ($file_path) = @_;
    unless ($file_path =~ m|^\/|) {
        my $file_name = File::Basename::basename($file_path);
        $file_path = File::Spec->rel2abs(File::Basename::dirname($file_path."/"));
        $file_path .= "/".$file_name;
    }
    $file_path =~ s|/{1,}|/|g;
    return $file_path;
}

sub get_base_dir_path {
    my $base_dir_path = $FindBin::Bin;
    return $base_dir_path;
}

sub get_base_file_name {
    my $base_file_name = $FindBin::Script;
    return $base_file_name;
}

sub get_config {
    my ($conf_file_path) = @_;
    my $config = "";
    if ($conf_file_path) {
        $conf_file_path = &complete_file_path($conf_file_path) unless ($conf_file_path =~ m|^\/|);
        if ((defined $conf_file_path) && (-f $conf_file_path) && (-s $conf_file_path)) {
            $config = &read_json_file($conf_file_path);
            if (ref $config eq "Config::JSON") {
                $config = $config->{config}
            } else {
                if (HALLOW_DEBUG) {
                    warnf ("Can't get Config::JSON object");
                }
            }
        } else {
            if (HALLOW_DEBUG) {
                warnf ("conf_file_path isn't defined") unless (defined $conf_file_path);
                warnf ("conf_file_path isn't there") unless (-f $conf_file_path);
                warnf ("conf_file_path doesn't have data") unless (-s $conf_file_path);
            }
        }
    } else {
        if (HALLOW_DEBUG) {
            warnf ("First argument should be path of configure file");
        }
    }
    return $config;
}

sub read_json_file {
    my ($file_path) = @_;
    my $json = "";
    if ((defined $file_path) && (-f $file_path) && (-s $file_path)){
        eval { $json = Config::JSON->new($file_path); };
        if ($@) {
            if (HALLOW_DEBUG) {
                warnf ("Can't read this JSON file");
            }
        }
    } else {
        if (HALLOW_DEBUG) {
            warnf ("conf_file_path isn't defined") unless (defined $file_path);
            warnf ("conf_file_path isn't there") unless (-f $file_path);
            warnf ("conf_file_path doesn't have data") unless (-s $file_path);
        }
    }
    return $json;
}

sub add_leading_zeros {
    my ($num, $digit_num) = @_;
    my $result = "";
    if ((defined $num) && (Scalar::Util::looks_like_number($num))) {
        $digit_num = 1 unless (defined $digit_num);
        my $length = 1;
        my $tmp = $num;
        while (int($tmp / 10) > 0) {
            $length++;
            $tmp = int($tmp / 10);
        }
        my $diff = $digit_num - $length;
        while ($diff > 0) {
            $num = "0".$num;
            $diff--;
        }
        $result = $num;
    }  else {
        if (HALLOW_DEBUG) {
            warnf ("First argument should be positive integer number") unless (defined $num);
        }
    }
    return $result;
}

#sub add_trailing_zeros {
#}

1;

__END__

=encoding utf-8

=head1 NAME

Hallow::Util - It's new $module

=head1 SYNOPSIS

    use Hallow::Util;

=head1 DESCRIPTION

Hallow::Util is ...

=head1 LICENSE

Copyright (C) Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut
