package YoutubeDL::Wrapper::Test::Basics;

use Moose;
use YoutubeDL::Wrapper;
use IPC::Open3::Simple;
use Test::More tests => 1 # does_youtubedl_start
                      + 4 # do_we_support_this_youtubedl_version
                      + 1 # can_we_read_a_config_file
;

our @EXPORT_OK = qw/
    does_youtubedl_start
    do_we_support_this_youtubedl_version
    can_we_read_a_config_file
/;
    #can_we_read_a_downloads_file

sub does_youtubedl_start {
    my $ytw = YoutubeDL::Wrapper->new();
    my $output = "";
    my $observed_version = $ytw->config->executable_version;
    # We can get an observed_version, that's a good sign
    ok(defined $observed_version->{year});
}

sub do_we_support_this_youtubedl_version {
    my $ytw = YoutubeDL::Wrapper->new();
    my $supported_version = $ytw->config->supported_executable_version;
    my $observed_version = $ytw->config->executable_version;
    # That's 4 times
    ok($observed_version->{$_} >= $supported_version->{$_}) 
        for keys %{$supported_version};
}

sub can_we_read_a_config_file {
    my $ytw = YoutubeDL::Wrapper->new({
        config_filename => './t/test_config.yml'
    });
    use Data::Dumper;
    warn Dumper $ytw;
    warn Dumper $ytw->config_filename;
    my $config = $ytw->config->config_yaml;
    ok(defined $config);
}

sub can_we_read_a_downloads_file {
    my $ytw = YoutubeDL::Wrapper->new({
        config_filename => './t/test_config.yml'
    });
    my $results = $ytw->config->get_downloads;
}

1;
