use utf8;
package Lab::Labels::XeTeX;
use 5.020;
use strict;
use base 'Template';
use Path::Tiny qw< path tempdir >;
use IPC::Run qw< run >;
use namespace::autoclean;


# This regex is lifted and modified from the source of LaTeX::Encode for a
# purely plain-TeX solution to encoding the TeX special characters
my %encoding = (
    chr(0x0023) => '\\#',
    chr(0x0024) => '\\$',
    chr(0x0025) => '\\%',
    chr(0x0026) => '\\&',
    chr(0x005c) => '{\\char`\\\\}',
    chr(0x005e) => '\\^{ }',
    chr(0x005f) => '\\_',
    chr(0x007b) => '{\\char123}',
    chr(0x007d) => '{\\char125}',
    chr(0x007e) => '{\\char`~}',
);

my $encoding_re = join q{}, sort keys %encoding;
$encoding_re =~ s{ ([#\[\]\\\$]) }{\\$1}gmsx;
$encoding_re = eval "qr{[$encoding_re]}x";


my $DEFAULTS = {
    INCLUDE_PATH        => [ path(__FILE__)->parent(4)->child("templates/xetex") ],
    FILTERS             => {
        escape_text => sub {
            $_[0] =~ s{ ($encoding_re) } { $encoding{$1} }gsrxe
        },
    },
};

sub new {
    my $self   = shift;
    return $self->SUPER::new($DEFAULTS, @_);
}

sub process {
    my ($self, $template, $context, $pdf_ref) = @_;
    my $tmpdir = tempdir("lab-labels-xetex-XXXXXXXX");
    my $tex_file = $tmpdir->child("labels.tex");
    $self->SUPER::process($template, $context, "".$tex_file->absolute, binmode => ':utf8') or die $self->error;
    my $log;
    run ['xetex', '-interaction=nonstopmode', "-output-directory=$tmpdir", $tex_file], '>&', \$log;
    my $pdf_file = $tmpdir->child("labels.pdf");
    $$pdf_ref = path($pdf_file)->slurp_raw;
    return 1;
}

1;
