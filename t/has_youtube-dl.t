use YoutubeDL::Wrapper::Test::Basics qw/
    does_youtubedl_start
    do_we_support_this_youtubedl_version
/;

use Carp;

YoutubeDL::Wrapper::Test::Basics->does_youtubedl_start();
YoutubeDL::Wrapper::Test::Basics->do_we_support_this_youtubedl_version();
