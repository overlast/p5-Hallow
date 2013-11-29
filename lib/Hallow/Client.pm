package Hallow::Client;

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

use Jubatus;

sub get_ml_client {
    my ($self, $module_name) = @_;
    my $config = $self->{config};
    my $recipe_name = $self->{recipe_name};
    my $platform = $config->{$recipe_name}->{$module_name}->{platform};
    my $ml_client = "";
    if ($platform eq "jubatus") {
        my $jubatus_conf = $config->{platform}->{jubatus};
        my $server_name = $jubatus_conf->{server_name};
        my $host = $jubatus_conf->{host};
        my $port = $jubatus_conf->{port};
        $server_name =~ s|juba||;
        $ml_client = Jubatus->get_client($host, $port, $server_name);
    }
    return $ml_client;
}

sub get_max_result_num {
    my ($self, $module_name) = @_;
    my $max_result_num = 10; #default
    my $config = $self->{config};
    my $recipe_name = $self->{recipe_name};
    $max_result_num = $config->{$recipe_name}->{$module_name}->{max_result_num} if (exists $config->{$recipe_name}->{$module_name}->{max_result_num});
    return $max_result_num;
}
