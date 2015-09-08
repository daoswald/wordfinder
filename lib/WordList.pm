package WordList;
use strict;
use warnings;
use Moose;
use namespace::autoclean;

has words => (is => 'ro', isa => 'ArrayRef[Word]');

sub words_spelled {
  my ($self, $try) = @_;
  my @found;
  foreach my $dict_word (@{$self->words}) {
    push @found, $dict_word->word
        if $dict_word->can_be_spelled_from($try);
  }
  return \@found;
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
