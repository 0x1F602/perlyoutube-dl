package YoutubeDL::Wrapper 1.0;
use Moose;
use YoutubeDL::Wrapper::Config;
use IPC::Open3::Simple;
use Tie::IxHash;
use Cwd;
use Parallel::ForkManager;
has 'executable' => (
    is => 'ro',
    default => 'youtube-dl',
);

has 'config_filename' => (
    is => 'rw',
    isa => 'Str',
    default => 'config.yml',
    lazy => 1,
    writer => 'set_config_filename',
);

has 'config' => (
    is => 'rw',
    builder => '_get_config',
    lazy => 1,
);

has 'executable_version' => (
    is => 'ro',
    isa => 'HashRef',
    builder => '_get_executable_version',
    lazy => 1,
);

has 'files_to_download' => (
    is => 'ro',
    isa => 'HashRef',
    builder => '_get_files_to_download',
    lazy => 1,
);

sub _get_executable_version {
    my ($self) = @_;
    my $observed_version = {};
    my $executable = $self->executable;
    my $output = $self->run(["--version"]);
    my @matches = $output->{stdout} =~ 
        m/(\d\d\d\d)\.(\d\d)\.(\d\d)\.(\d+)/;
    if (scalar @matches == 4) {
        $observed_version->{$_} = shift @matches for qw/year month day release/;
    }
    return $observed_version;
}

sub _get_config {
    my ($self) = @_;
    my $config = YoutubeDL::Wrapper::Config->new(config_filename => $self->config_filename);
    return $config;
}

sub run {
    my ($self, $command) = @_;
    $command = $command // [];
    $command = [$self->executable, @{$command}];

    my $output = {
        stdout => '',
        stderr => '',
    };

    my $process = IPC::Open3::Simple->new(
        out => sub {
            my $line = shift;
            $output->{stdout} .= "$line\n";
        },
        err => sub {
            my $line = shift;
            $output->{stderr} .= "$line\n";
        }
    );

    my $corrected = join(" ", @{$command});
    use Data::Dumper;
    warn "Inside run";
    warn Dumper $corrected;
    warn Dumper $command;
    warn "After run point";
    my  $retval = $process->run($corrected);
    return $output;
}

sub _get_files_to_download {
    my ($self) = @_;
    my $files = {};
    $files = $self->config->downloads;
    return $files;
}

sub _merge_options {
    my ($self, $globals, $locals) = @_;
    my $merged_options = {};
    $merged_options = {
        %{$globals},
        %{$locals}
    };
    return $merged_options;
}

sub get_jobs {
    my ($self) = @_;
    my $global_executable_options = $self->config->global_executable_options;
    my $jobs = $self->files_to_download; 
    for my $url (keys %{$jobs}) {
        # merge the job and global executable options
        # always allow individual executable options
        # to override the global defaults
        $jobs->{$url}->{executable_options} = 
            $self->_merge_options($global_executable_options, 
                $jobs->{$url}->{executable_options});
    }
    return $jobs;
}

=head2 _convert_options_to_cli

Takes a Tie::IxHash object of executable options from config files and converts
them into something that the run method can use.
=cut

sub _convert_options_to_cli {
    my ($self, $exec_opts) = @_;

    my @cli_options = ();

    for my $key ($exec_opts->Keys) {
        my $option = $exec_opts->FETCH($key);

        if (uc($option) eq 'OFF') {
            next;
        }
        elsif (uc($option) eq 'ON') {
            push @cli_options, "--" . $key;
        }
        else {
            if ($option eq '' ||
                not defined $option) {
                next; # in the future, this should be a custom exception
            }

            push @cli_options, "--" . $key;
            push @cli_options, $option;
        }
    }
    
    return [@cli_options];
}

=head2 run_jobs

Gets the list of jobs, converts their options to CLI ready options, executes each one with youtube-dl

=cut

sub run_jobs {
    my ($self, $jobs) = @_;
    my $stats = {};
    my $old_working_directory = getcwd();
    # Change directory to tempdir
    my $tmpdir = $self->config->{config_yaml}->{tmpdir} // '.';
        use Data::Dumper;
    chdir $tmpdir;
    # Loop over jobs here
    my $pm = Parallel::ForkManager->new(2);
    DOWNLOAD_LOOP:
    for my $url (keys %{$jobs}) {
        my $pid = $pm->start and next DOWNLOAD_LOOP;
        warn Dumper $url;
        my $cli_opts = $jobs->{$url}->{cli_options} = 
            $self->_convert_options_to_cli($jobs->{$url}->{executable_options});
        push @{$cli_opts}, $url;
        warn "Printing cli_opts here";
        warn Dumper $cli_opts;
        warn "Done";
        $stats->{$url} = $self->run($cli_opts);
        $pm->finish;
    }
    $pm->wait_all_children;
    chdir $old_working_directory;
    warn "Stats";
    warn Dumper $stats;
    return $stats;
}

no Moose;
__PACKAGE__->meta->make_immutable;
