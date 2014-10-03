package YoutubeDL::Wrapper::Config;
use Moose;
extends 'YoutubeDL::Wrapper';

use YAML::XS qw/LoadFile/;

has 'downloads' => (
    is => 'ro',
    builder => 'get_downloads',
    lazy => 1,
);

has 'executable' => (
    is => 'rw',
    default => 'youtube-dl',
    lazy => 1,
);

has 'config_yaml' => (
    is => 'ro',
    builder => '_read_config_yaml',
    lazy => 1,
);

has 'executable_version' => (
    is => 'ro',
    builder => '_get_executable_version',
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

sub _get_executable_version {
    my ($self) = @_;
    my $observed_version = {};
    my $executable = $self->executable;
    my $output = $self->run("$executable -v");
    my @matches = $output->{stderr} =~ 
        m/\[debug\] youtube-dl version (?<year>\d\d\d\d).(?<month>\d\d).(?<day>\d\d).(?<release>\d+)/;
    if (scalar @matches == 4) {
        $observed_version->{$_} = shift @matches for qw/year month day release/;
    }
    return $observed_version;
}

sub get_downloads {
    my ($self) = @_;
    return [];
}

no Moose;
__PACKAGE__->meta->make_immutable;
