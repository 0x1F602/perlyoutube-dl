package YoutubeDL::Wrapper::Config;
use Moose;

use YAML::XS qw/LoadFile/;

has 'config_filename' => (
    is => 'rw',
    default => 'config.yml',
    isa => 'Str',
    lazy => 1,
);

has 'downloads' => (
    is => 'ro',
    builder => 'get_downloads',
    lazy => 1,
);

has 'executable' => (
    is => 'ro',
    default => 'youtube-dl',
);

has 'config_yaml' => (
    is => 'ro',
    builder => '_read_config_yaml',
    lazy => 1,
);

has 'supported_executable_version' => (
    is => 'ro',
    builder => '_get_supported_executable_version',
    lazy => 1,
);

sub _read_config_yaml {
    my ($self) = @_;
#    use Data::Dumper;
#    warn Dumper $self;
    #$self->set_config_filename('yellow.yml');
    #my $cf = $self->config_filename;
    #warn "Config $cf";
    my $yaml = LoadFile($self->config_filename);
#    use Data::Dumper;
#    warn Dumper $yaml;
    return $yaml;
}

sub _get_supported_executable_version {
    my ($self) = @_;
    return $self->config_yaml->{supported_version};
}

sub get_downloads {
    my ($self) = @_;
    return [];
}

no Moose;
__PACKAGE__->meta->make_immutable;
