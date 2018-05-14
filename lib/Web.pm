package Web;

use 5.020;
use strict;
use warnings;

use Web::Simple;
use JSON::MaybeXS;
use Path::Tiny;
use Plack::Request;
use Plack::App::File;
use Labels;

sub dispatch_request {
    (
        'POST + /stickers' => sub {
            my $self = shift;
            my $req = Plack::Request->new($_[PSGI_ENV]);

            if ($req->content_type !~ /^application\/json/) {
                return [ 415, ['Content-type', 'application/json'], ['{"error":"Client error"}']];
            }

            my $body = decode_json($req->content);
            my $labels = Labels->new(
                type   => $body->{type},
                labels => $body->{labels},
            );

            return [ 200, ['Content-type', 'application/pdf'], [ $labels->as_pdf ] ];
        },

        '/...' => sub {
            state $static = Plack::App::File->new(root => path(__FILE__)->parent(2)->child("root"))->to_app;
            $static;
        }
    )
}

Web->run_if_script;
