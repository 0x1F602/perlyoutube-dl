package YoutubeDL::Wrapper 1.0;
use Moose;
use YoutubeDL::Wrapper::Config;

has 'config_filename' => (
    is => 'rw',
    #default => 'wrong.yml',
    isa => 'Str',
    #lazy => 1,
    writer => 'set_config_filename',
);

has 'config' => (
    is => 'rw',
    builder => '_get_config',
    lazy => 1,
);

#sub set_config_filename {
#    my ($self, $fn) = @_;
#    warn "Filename $fn";
#    #$self->config_filename = $fn;
#    return $fn;
#}

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
