use Test::More;
use Data::Dumper;
use YoutubeDL::Wrapper;

my $test_config = {
    config_filename => './t/test_config.yml',
};

my $test_url = "http://www.youtube.com/watch?v=Yl2w3ck1gbA";

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
    ok(defined $ytw->config->global_executable_options);
    note Dumper $ytw->config->global_executable_options;
};

subtest can_we_run_executable_options => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    my $opts = $ytw->config->global_executable_options;
    note "Looking at \$opts";
    note Dumper $opts;
    my $runnable_opts = [];
    note Dumper $ytw->config->get_executable_options($opts);
    push @{$runnable_opts}, $ytw->config->get_executable_options($opts);
    my $output = $ytw->run($runnable_opts);
    note Dumper $output;
    ok(defined $output);
};

subtest can_we_load_jobs => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    my $jobs = $ytw->get_jobs();
    note Dumper $jobs;
    my $sample_jobs = {
          'album' => 'vvinter rainbovv',
          'artist' => 'vvinter rainbovv',
          'comment' => 'ft. Caliix',
          'song' => 'Departure',
          'executable_options' => Tie::IxHash->new((
                            'audio-quality' => 7,
                            'audio-format' => 'mp3',
                            'write-info-json' => 'ON',
                            'simulate' => 'ON',
                            'extract-audio' => 'ON',
                            'embed-thumbnail' => 'ON'
                           ))->SortByKey,
          'type' => 'mp3',
    };
    note Dumper $sample_jobs;
    is_deeply($jobs->{$test_url}, $sample_jobs);
    note Dumper $jobs;
};

subtest can_we_translate_options => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    my $jobs = $ytw->get_jobs();
    my $config_exec_opts = $jobs->{$test_url}->{executable_options};
    my $expected_cli_opts = [
        '--audio-format', 'mp3',
        '--audio-quality', '7', 
        '--embed-thumbnail',
        '--extract-audio',
        '--simulate',
        '--write-info-json',
    ];
    my $real_cli_opts = $ytw->_convert_options_to_cli($config_exec_opts);
    is_deeply($real_cli_opts, $expected_cli_opts);
};

subtest can_we_execute_job => sub {
    my $ytw = YoutubeDL::Wrapper->new($test_config);
    my $jobs = $ytw->get_jobs();
    my $exec = $ytw->run_jobs($jobs);

    my ($youtube_link) = $test_url =~ m/v=([\w]+)$/g;

    is($exec->{$test_url}->{stdout} =~ m/\[youtube\] $youtube_link: Downloading webpage/,           1);
    is($exec->{$test_url}->{stdout} =~ m/\[youtube\] $youtube_link: Extracting video information/,  1);
    is($exec->{$test_url}->{stdout} =~ m/\[youtube\] $youtube_link: Downloading DASH manifest/,     1);

    is($exec->{$test_url}->{stderr}, '');
};

done_testing();
