package Devel::Mutator::Generator;

use strict;
use warnings;

use PPI;

my %operators_map = (
    '+'   => '-',
    '=='  => '!=',
    '++'  => '--',
    '=~'  => '!~',
    '*'   => '/',
    'gt'  => 'lt',
    'ge'  => 'le',
    '>'   => '<',
    '>='  => '<=',
    '||'  => '&&',
    'and' => 'or',
    'eq'  => 'ne',
    '//'  => '||',
    '//=' => '||=',
);
my %reversed_operators_map = reverse %operators_map;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub generate {
    my $self = shift;
    my ($code) = @_;

    my $ppi = PPI::Document->new(\$code);

    my @mutants;
    if (my $operators = $ppi->find('PPI::Token::Operator')) {
        foreach my $operator (@$operators) {
            my $new_operator = find_map($operator->content);

            next unless $new_operator;

            my $old_operator = $operator->content;
            $operator->set_content($new_operator);

            push @mutants,
              {
                id      => $ppi->hex_id,
                content => $ppi->serialize
              };

            $operator->set_content($old_operator);
        }
    }

    return @mutants;
}

sub find_map {
    my ($operator) = @_;

    return $operators_map{$operator} if exists $operators_map{$operator};
    return $reversed_operators_map{$operator}
      if exists $reversed_operators_map{$operator};
    return;
}

1;
