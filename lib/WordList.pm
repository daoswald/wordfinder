package WordList;
use strict;
use warnings;
use Moose;
use namespace::autoclean;

has words => (is => 'ro', isa => 'ArrayRef[Word]');

sub words_spelled {return [map {$_->can_be_spelled_from($_[1]) ? $_->word : ()} @{$_[0]->words}];}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
