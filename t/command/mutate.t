use strict;
use warnings;

use Test::More;
use File::Temp;

use Devel::Mutator::Command::Mutate;

subtest 'creates mutants' => sub {
    my $dir = File::Temp->newdir(CLEANUP => 0);

    open my $fh, '>', "$dir/foo.pm";
    print $fh 'print 1 + 1';
    close $fh;

    my $command = _build_command(root => $dir);
    $command->run("$dir/foo.pm");

    ok -d "$dir/mutants";
    ok -d "$dir/mutants/0fae63c0f5b0fe3dcf214d7a1d9a8145";
    ok -f "$dir/mutants/0fae63c0f5b0fe3dcf214d7a1d9a8145/$dir/foo.pm";
};

sub _build_command {
    Devel::Mutator::Command::Mutate->new(@_);
}

done_testing;
