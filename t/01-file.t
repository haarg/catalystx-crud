use Test::More tests => 15;
use lib qw( lib t/lib );
use_ok('CatalystX::CRUD::Model::File');
use_ok('CatalystX::CRUD::Object::File');

use Catalyst::Test 'MyApp';
use Data::Dump qw( dump );
use HTTP::Request::Common;

$ENV{CXCRUD_TEST} = 1;    # we want stack traces in exceptions

###########################################
# set up the test env and config
ok( get('/foo'), "get /foo" );

ok( my $response = request('/file/search'), "response for /file/search" );

#dump( $response->headers );

is( $response->headers->{status}, '302', "response was redirect" );

ok( get('/autoload'), "get /autoload" );

###########################################
# do CRUD stuff

my $res;

# create
ok( $res = request(
        POST( '/file/testfile/save', [ content => 'hello world' ] )
    ),
    "POST new file"
);

is( $res->content,
    '{ content => "hello world", file => "testfile" }',
    "POST new file response"
);

# read the file we just created
ok( $res = request( HTTP::Request->new( GET => '/file/testfile/view' ) ),
    "GET new file" );

#diag( $res->content );

like( $res->content, qr/content => "hello world"/, "read file" );

# update the file
ok( $res = request(
        POST( '/file/testfile/save', [ content => 'foo bar baz' ] )
    ),
    "update file"
);

like( $res->content, qr/content => "foo bar baz"/, "update file" );

# delete the file

ok( $res = request( POST( '/file/testfile/rm', [] ) ), "rm file" );

#diag( $res->content );

# confirm it is gone
ok( $res = request( HTTP::Request->new( GET => '/file/testfile/view' ) ),
    "confirm we nuked the file" );

#diag( $res->content );

like( $res->content, qr/content => undef/, "file nuked" );
