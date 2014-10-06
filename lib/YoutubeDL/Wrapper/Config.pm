package YoutubeDL::Wrapper::Config;
use Moose;

use YAML::XS qw/LoadFile/;

has 'config_filename' => (
    is => 'rw',
    default => 'config.yml',
    isa => 'Str',
    lazy => 1,
);

has 'download_filename' => (
    is => 'rw',
    isa => 'Str',
    builder => '_get_download_filename',
    lazy => 1,
);

has 'downloads' => (
    is => 'ro',
    builder => '_get_downloads',
    lazy => 1,
);

has 'config_yaml' => (
    is => 'ro',
    builder => '_read_config_yaml',
    lazy => 1,
);

has 'download_yaml' => (
    is => 'ro',
    builder => '_read_download_yaml',
    lazy => 1,
);

has 'supported_executable_version' => (
    is => 'ro',
    builder => '_get_supported_executable_version',
    lazy => 1,
);

has global_executable_options => (
    is => 'rw',
    isa => 'HashRef',
    builder => '_get_global_executable_options',
    lazy => 1,
);

sub _get_global_executable_options {
    my ($self) = @_;
    my $yaml = $self->config_yaml->{executable_options};
    return $yaml;
}

sub get_executable_options {
    my ($self, $yaml) = @_;
    my $opts = $yaml;
    my $final_opts = [];

    for my $k (keys %{$opts}) {     
        if ($opts->{$k} eq "ON") {
            push @{$final_opts}, "--$k";
        }
        elsif ($opts->{$k} eq "Off") {
            # Do nothing!!
        }
        else {
            my $val = $opts->{$k};
            push @{$final_opts}, "--$k " . $opts->{$k};
        }
    }

    return $final_opts;
}

sub _get_download_filename {
    my ($self) = @_;
    my $filename = $self->config_yaml->{download_filename};
    return $filename;
}

sub _read_config_yaml {
    my ($self) = @_;
    my $yaml = LoadFile($self->config_filename);
    return $yaml;
}

sub _get_supported_executable_version {
    my ($self) = @_;
    return $self->config_yaml->{supported_version};
}

sub _get_downloads {
    my ($self) = @_;
    my $d = $self->download_yaml;
    return $d;
}

sub _read_download_yaml {
    my ($self) = @_;
    my $yaml = LoadFile($self->download_filename);
    return $yaml;
}

no Moose;
__PACKAGE__->meta->make_immutable;
