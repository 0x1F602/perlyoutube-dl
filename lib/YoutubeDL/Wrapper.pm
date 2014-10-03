package YoutubeDL::Wrapper 1.0;
use Moose;
use YoutubeDL::Wrapper::Config;
use IPC::Open3::Simple;

has 'config_filename' => (
    is => 'rw',
    default => 'config.yml',
    isa => 'Str',
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
    builder => '_get_executable_version',
    lazy => 1,
);


#sub set_config_filename {
#    my ($self, $fn) = @_;
#    warn "Filename $fn";
#    #$self->config_filename = $fn;
#    return $fn;
#}
sub _get_executable_version {
    my ($self) = @_;
    my $observed_version = {};
    my $executable = $self->config->executable;
    my $output = $self->run("$executable -v");
    my @matches = $output->{stderr} =~ 
        m/\[debug\] youtube-dl version (?<year>\d\d\d\d).(?<month>\d\d).(?<day>\d\d).(?<release>\d+)/;
    if (scalar @matches == 4) {
        $observed_version->{$_} = shift @matches for qw/year month day release/;
    }
    return $observed_version;
}

sub _get_config {
    my ($self) = @_;
    warn $self->config_filename;
    my $config = YoutubeDL::Wrapper::Config->new(config_filename => $self->config_filename);
    return $config;
}

sub run {
    my ($self, $command) = @_;
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
    my  $retval = $process->run($command);
    return $output;
}

no Moose;
__PACKAGE__->meta->make_immutable;
