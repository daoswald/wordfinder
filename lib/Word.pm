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
1;
