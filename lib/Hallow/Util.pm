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

sub read_json_file {
    my ($file_path) = @_;
    my $json = Config::JSON->new($file_path);
    return $json;
}

sub complete_file_path {
    my ($file_path) = @_;
    unless ($file_path =~ m|^\/|) {
        my $file_name = File::Basename::basename($file_path);
        $file_path = File::Spec->rel2abs(File::Basename::dirname($file_path."/"));
        $file_path .= "/".$file_name;
    }
    return $file_path;
}

sub get_config {
    my ($conf_file_path) = @_;
    my $config = "";
    if ($conf_file_path) {
        $conf_file_path = &complete_file_path($conf_file_path) unless ($conf_file_path =~ m|^\/|);
        if (-f $conf_file_path) {
            $config = &read_json_file($conf_file_path);
            $config = $config->{config};
        } else {
            $config = "Can't find a configure file";
        }
    } else {
        $config = "Con't get a path of a configure file";
    }
    return $config;
}

sub get_base_dir_path {
    my $base_dir_path = File::Spec->rel2abs(dirname(__FILE__))."/../";
    return $base_dir_path;
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
