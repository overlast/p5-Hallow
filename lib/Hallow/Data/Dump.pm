package Hallow::Data::Dump;

#use 5.008005;
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

use Hallow::DateTime;

sub get_dump_file_path {
    my ($param, $dir_path, $dt) = @_;
    my $path = "";
    if ((ref $param eq "HASH") && (-d $dir_path) && (ref $dt eq "DateTime")) {
        my $ext = "";
        $ext = ".".$param->{file_ext} if (exists $param->{file_ext});
        my $ymd_stamp = Hallow::DateTime::get_ymd_stamp($param, $dt);
        if ($ymd_stamp) {
            $path = $dir_path."/".$ymd_stamp.$ext;
            $path =~ s|/{1,}|/|g;
        } else {
            warnf "Can't get ymd_stamp" if (HALLOW_DEBUG);
        }
    } else {
        if (HALLOW_DEBUG) {
            warnf "First argument should be HASH ref" unless (ref $param eq "HASH");
            warnf "Second argument should be directory path" unless (-d $dir_path);
            warnf "Third argument should be DateTime object" unless (ref $dt eq "DateTime");
        }
    }
    return $path;
}

sub get_dump_dir_path {
    my ($param, $base_dir_path, $dt) = @_;
    my $path = "";
    if ((ref $param eq "HASH") && (exists $param->{dump_dir_path}) && (-d $base_dir_path)) {
        $path = $param->{dump_dir_path};
        unless ($path =~ m|^\/|) {
            $path = $base_dir_path."/".$path;
        }
        if ((exists $param->{is_use_daily_directly}) && ($param->{is_use_daily_directly} == 0)) {
        } else {
            if (ref $dt eq "DateTime") {
                my $ymd = $dt->ymd("");
                $path .= "/$ymd/";
            } else {
                warnf "Third argument should be DateTime object" if (HALLOW_DEBUG);
            }
        }
        $path =~ s|/{1,}|/|g;
        mkdirp($path) unless (-d $path);
    } else {
        if (HALLOW_DEBUG) {
            warnf "First argument should be HASH ref" unless (ref $param eq "HASH");
            warnf "First HASH ref argument have dump_dir_path field" unless (exists $param->{dump_dir_path});
            warnf "Second argument should be directly path" unless (-d $base_dir_path);
        }
    }
    return $path;
}

sub mkdirp {
    my ($path) = @_;
    my $is_mkdirp = -1;
    if (defined $path) {
        system("mkdir -p $path");
    } else {
        warnf "First argument should be file path" if (HALLOW_DEBUG);
    }
    return $is_mkdirp;
}

1;

__END__

=encoding utf-8

=head1 NAME

Hallow::Data::Dump - It's new $module

=head1 SYNOPSIS

    use Hallow::Data::Dump;

=head1 DESCRIPTION

Hallow::Data::Dump is ...

=head1 LICENSE

Copyright (C) Toshinori Sato (@overlast).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Toshinori Sato (@overlast) E<lt>overlasting@gmail.comE<gt>

=cut
