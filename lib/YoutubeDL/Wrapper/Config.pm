package YoutubeDL::Wrapper::Config;
use Moose;
extends 'YoutubeDL::Wrapper';

has 'downloads' => (
    is => 'ro',
    builder => 'get_downloads',
);

has 'executable' => (
    is => 'rw',
    default => 'youtube-dl',
);

has 'config_filehandle' => (
    is => 'ro',
    builder => '_get_config_filehandle',
    lazy => 1,
);

has 'config_filename' => (
    is => 'rw',
    default => 'config.yml',
);

has 'executable_version' => (
    is => 'ro',
    builder => '_get_executable_version',
    lazy => 1,
);

has 'supported_executable_version' => (
    is => 'ro',
    default => sub {
        return {
            year => '2014',
            month => '09',
            day => '29',
            release => '2',
        };
    }
);

sub _get_config_filehandle {
    my ($self) = @_;
# Find the file via its name and open it as a file handler
    my $fn = $self->config_filename;
    return open($fn);
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

__PACKAGE__->meta->make_immutable;
1;
