use YoutubeDL::Wrapper::Test::Basics qw/
    can_we_read_a_config_file
    does_youtubedl_start
    do_we_support_this_youtubedl_version
    can_we_read_a_downloads_file
/;
use Carp;

my $ytwrapper = YoutubeDL::Wrapper::Test::Basics->new();
$ytwrapper->does_youtubedl_start();
$ytwrapper->do_we_support_this_youtubedl_version();
$ytwrapper->can_we_read_a_config_file();
TODO: {
    $ytwrapper->can_we_read_a_downloads_file();
}
