package LaTeX;
use 5.020;
use strict;
use base 'Template::Latex';
use LaTeX::Encode qw< latex_encode >;
use Path::Tiny;
use namespace::autoclean;

my $DEFAULTS = {
    INCLUDE_PATH        => [ path(__FILE__)->parent(2)->child("latex") ],
    LATEX_FORMAT        => 'pdf',
    TEMPLATE_EXTENSION  => '.tex',
    WRAPPER             => 'wrapper.tt',
    FILTERS             => {
        escape_text => sub {
            # Replace unknown characters with a space instead of
            # \unmatched{codepoint}, since the latter causes errors.
            latex_encode($_[0], {
                unmatched => sub { ' ' },
            });
        },
    },
};

sub new {
    my $self   = shift;
    return $self->SUPER::new($DEFAULTS, @_);
}

1;
