package Lab::Labels::Web;

use 5.020;
use strict;
use warnings;

use Web::Simple;
use JSON::MaybeXS;
use Path::Tiny;
use Plack::Request;
use Plack::App::File;
use Lab::Labels;

sub dispatch_request {
    (
        'POST + /labels/* + %sku=&labels=&copies=&as_barcodes~&gridlines~' => sub {
            my ($self, undef, $sku, $text, $copies, $as_barcodes, $gridlines) = @_;
            my @lines = split /\r?\n/, $text;
            my @labels =
                map { $as_barcodes ? { %$_, barcode => $_->{text} } : $_ }
                map { +{ text => $_, copies => $copies } }
                map { s/( \\ |\t)/\n/gr }
                    @lines;

            my $labels = Lab::Labels->new(
                type   => $sku,
                labels => \@labels,
                gridlines => !!$gridlines,
            );
            return [ 200, ['Content-type', 'application/pdf'], [ $labels->as_pdf ] ];
        },

        'POST + /stickers' => sub {
            my $self = shift;
            my $req  = Plack::Request->new($_[PSGI_ENV]);
            my $ct   = $req->headers->content_type;

            return [ 415, ['Content-type', 'application/json'], ['{"error":"Client error"}']]
                unless $ct and $ct eq 'application/json';

            my $body = decode_json($req->content);
            my $labels = Lab::Labels->new(
                type   => $body->{type},
                labels => $body->{labels},
                gridlines => $body->{gridlines},
            );

            return [ 200, ['Content-type', 'application/pdf'], [ $labels->as_pdf ] ];
        },

        '/' => sub {
            redispatch_to '/index.html';
        },


        '/...' => sub {
            state $static = Plack::App::File->new(root => path(__FILE__)->parent(4)->child("root"))->to_app;
            $static;
        }
    )
}

1;
