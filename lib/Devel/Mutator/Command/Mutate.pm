package Devel::Mutator::Command::Mutate;

use strict;
use warnings;

use File::Slurp    ();
use File::Path     ();
use File::Basename ();
use File::Spec;
use Devel::Mutator::Generator;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{root}      = $params{root}      || '.';
    $self->{generator} = $params{generator} || Devel::Mutator::Generator->new;

    return $self;
}

sub run {
    my $self = shift;
    my (@files) = @_;

    foreach my $file (@files) {
        next unless -f $file;

        print "Reading $file ... \n";
        my $content = File::Slurp::read_file($file);

        print "Generating mutants ... ";
        my @mutants = $self->{generator}->generate($content);

        print scalar(@mutants), "\n";

        print "Saving mutants ... ";
        foreach my $mutant (@mutants) {
            my $new_path =
              File::Spec->catfile($self->{root}, 'mutants', $mutant->{id},
                $file);

            File::Path::make_path(File::Basename::dirname($new_path));

            File::Slurp::write_file($new_path, $mutant->{content});
        }
        print "ok\n";
    }

    return $self;
}

1;
