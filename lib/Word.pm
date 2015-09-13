package Word;

use Moose;
use strict;
use warnings;
use List::Util q/none/;
use namespace::autoclean;

# has word     => (is   => 'ro', isa     => 'Str'); # Isa checks are slow.
# 
# has _buckets => (is   => 'ro', isa     => 'HashRef',
#                  lazy => 1,    builder => '_build_buckets');
has word     => (is => 'ro');
has _buckets => (is => 'ro', lazy => 1, builder => '_build_buckets');

sub _build_buckets {
    my $self = shift;
    return $self->_bucketize($self->word);
}

sub _bucketize {
    my %thash;
    $thash{$_}++ for split //, $_[1];
    return \%thash;
}

sub can_be_spelled_from {
    my ($self, $subject_letters) = @_;
    return 0 if length $subject_letters < length $self->word;
    my $subject_buckets = $self->_bucketize($subject_letters);
    return none {
        !exists $subject_buckets->{$_}
        || $subject_buckets->{$_} < $self->_buckets->{$_}
    } keys %{$self->_buckets};
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
