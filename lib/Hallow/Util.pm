package Hallow::Util;

use 5.008005;
use strict;
use warnings;

our $VERSION = "0.0.0_01";

use utf8;
use autodie;

use Config::JSON;
use File::Basename;
use File::Spec;
use FindBin;

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
        if (-f $conf_file_path) {
            $config = &read_json_file($conf_file_path);
            if (ref $config eq "Config::JSON") {
                $config = $config->{config}
            } else {
                $config = "It isn't Config::JSON object";
            }
        } else {
            $config = "Can't find a configure file";
        }
    } else {
        $config = "Con't get a path of a configure file";
    }
    return $config;
}

sub read_json_file {
    my ($file_path) = @_;
    my $json = "";
    if ((-f $file_path) && (-s $file_path)){
        eval { $json = Config::JSON->new($file_path); };
        if ($@) { $json = "Can't read this JSON file"; }
    }
    return $json;
}

sub num_to_num_string {
    my ($num, $digit) = @_;
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
