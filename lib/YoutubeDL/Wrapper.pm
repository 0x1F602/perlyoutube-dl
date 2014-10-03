package YoutubeDL::Wrapper 1.0;
use Moose;
use YoutubeDL::Wrapper::Config;

has 'config' => (
    is => 'rw',
    builder => '_get_config',
    lazy => 1,
);

sub _get_config {
    my ($self) = @_;
    my $config = YoutubeDL::Wrapper::Config->new();
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

#__PACKAGE__->meta->make_immutable;
1;
