package YoutubeDL::Wrapper::Test::Basics;

use YoutubeDL::Wrapper;
use IPC::Open3::Simple;
use Test::More tests => 1 # does_youtubedl_start
                      + 4 # do_we_support_this_youtubedl_version
;

@EXPORT_OK=qw/
    does_youtubedl_start
    do_we_support_this_youtubedl_version
/;

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

1;
