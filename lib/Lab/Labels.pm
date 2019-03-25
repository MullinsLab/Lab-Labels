use 5.020;
use utf8;

package Lab::Labels;
use Moo;
use Types::Standard qw< :types slurpy >;
use Types::Common::Numeric qw< :types >;
use Types::Common::String qw< NonEmptyStr >;
use Path::Tiny;
use Lab::Labels::LaTeX;
use Lab::Labels::XeTeX;
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
            text    => Str,
            copies  => PositiveInt,
            barcode => Optional[Str],
            slurpy HashRef
        ]
    ],
    required => 1,
);

has gridlines => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
    coerce  => 1,
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

has engine => (
    is => 'lazy',
    isa => InstanceOf["Template"],
);

sub _build_engine {
    my $self = shift;
    return Lab::Labels::XeTeX->new
        if $self->type =~ /^DTCR-[14]000$/;
    return Lab::Labels::LaTeX->new;
}


sub as_pdf {
    my $self    = shift;
    my $context = {
        labels => $self->labels,
        gridlines => $self->gridlines,
    };

    my $pdf;
    $self->engine->process($self->template->stringify, $context, \$pdf)
        or die sprintf "Error processing %s: %s", $self->template, $self->engine->error;
    return $pdf;
}

1;
