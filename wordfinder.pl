#!/usr/bin/env perl

package Word;

use Moose;

use strict;
use warnings;
use namespace::autoclean;

has word     => ( is => 'ro', isa => 'Str' );
has _buckets => ( is => 'ro', lazy => 1, builder => '_build_buckets', isa => 'HashRef' );

sub _build_buckets {
  my $self = shift;
  return $self->_bucketize($self->word);
}

sub _bucketize {
  my( $self, $word ) = @_;
  my %thash;
  $thash{$_}++ for split //, $word;
  return \%thash;
}

sub can_be_spelled_from {
  my( $self, $subject_letters ) = @_;
  return 0 if length $subject_letters < length $self->word;
  my $subject_buckets = $self->_bucketize($subject_letters);
  foreach my $letter ( keys %{$self->_buckets} ) {
    if( ! exists $subject_buckets->{$letter}
       || $subject_buckets->{$letter} < $self->_buckets->{$letter} ) {
      return 0;
    }
  }
  return 1;
}
__PACKAGE__->meta->make_immutable;

no Moose;

package WordList;
use strict;
use warnings;
use Moose;
use namespace::autoclean;

has words => ( is => 'ro', isa => 'ArrayRef[Word]' );

sub words_spelled {
  my( $self, $try ) = @_;
  my @found;
  foreach my $dict_word ( @{$self->words} ) {
    push @found, $dict_word->word if $dict_word->can_be_spelled_from( $try );
  }
  return \@found;
}

__PACKAGE__->meta->make_immutable;
no Moose;

package main;

use strict;
use warnings;

use File::Slurp;
use IO::Prompt::Tiny 'prompt';
use List::MoreUtils  'uniq';

my $wl = WordList->new( words =>
  [
    map {
      $_ = lc $_;
      Word->new( word => $_ );
    }
    grep { /^[a-z]{4,}$/i }
    read_file('/usr/share/dict/words', chomp => 1 )
  ]
);


while( 1 ) {
  my $letters = prompt 'Enter a set of letters (empty to exit)', '';
  last unless length $letters;
  print "$_\n" for
    sort { length $a <=> length $b || $a cmp $b }
    uniq @{$wl->words_spelled($letters)};
}
