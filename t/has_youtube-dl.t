use Test::More;
use Data::Dumper;
use YoutubeDL::Wrapper;

my $test_config = {
    config_filename => './t/test_config.yml',
};

subtest does_youtubedl_start => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    my $output = "";
    my $observed_version = $ytw->executable_version;
    # We can get an observed_version, that's a good sign
    ok(defined $observed_version->{year});
};

subtest do_we_support_this_youtubedl_version => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    my $supported_version = $ytw->config->supported_executable_version;
    my $observed_version = $ytw->executable_version;
    # That's 4 times
    is(scalar keys %{$supported_version}, 4);
    ok($observed_version->{$_} >= $supported_version->{$_}) 
        for keys %{$supported_version};
};

subtest can_we_read_a_config_file => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    note "YoutubeDL::Wrapper object";
    note Dumper $ytw;
    note "Config filename";
    note Dumper $ytw->config_filename;
    my $config = $ytw->config->config_yaml;
    ok(defined $config);
};

subtest can_we_read_a_downloads_file => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    my $results = $ytw->files_to_download;
    note Dumper $results;
    ok(defined $results);
};

subtest can_we_see_executable_options => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    ok(defined $ytw->config->executable_options);
    note Dumper $ytw->config->executable_options;
};

subtest can_we_run_executable_options => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    my $opts = $ytw->config->executable_options;
    my $url = "http://www.youtube.com/watch?v=Yl2w3ck1gbA";
    push @{$opts}, $url;
    my $output = $ytw->run($opts);
    note Dumper $output;
    ok(defined $output);
};

done_testing();
