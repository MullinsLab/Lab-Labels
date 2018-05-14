use 5.020;
use utf8;

package Labels;
use Moo;
use Types::Standard qw< :types slurpy >;
use Types::Common::Numeric qw< :types >;
use Types::Common::String qw< NonEmptyStr >;
use Path::Tiny;
use LaTeX;
use namespace::autoclean;

has type => (
    is       => 'ro',
    isa      => NonEmptyStr,
    required => 1,
);

has labels => (
    is       => 'ro',
    isa      => ArrayRef[
        Dict[
            text   => Str,
            copies => PositiveInt,
            slurpy HashRef
        ]
    ],
    required => 1,
);

has template => (
    is  => 'lazy',
    isa => InstanceOf["Path::Tiny"],
);

sub _build_template {
    my $self = shift;
    my $type = $self->type =~ s/[^A-Za-z0-9_-]//gr;
    return path("$type.tex");
}

sub as_pdf {
    my $self    = shift;
    my $context = {
        labels => $self->labels,
    };

    state $latex = LaTeX->new;

    my $pdf;
    $latex->process($self->template->stringify, $context, \$pdf)
        or die sprintf "Error processing %s: %s", $self->template, $latex->error;
    return $pdf;
}

1;
