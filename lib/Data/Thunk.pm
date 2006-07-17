package Data::Defer;
$Data::Defer::VERSION = '0.02';

use 5.006;
use strict;
use warnings;
use Exporter::Lite;
use Class::InsideOut qw( private register id );
our @EXPORT = qw( lazy defer );

private _defer => my %_defer;

use overload fallback => 1, map {
    $_ => \&force
} qw( bool "" 0+ ${} @{} %{} &{} *{} );

sub force (&) {
    &{$_defer{ id $_[0] }}
}

sub lazy (&) {
    my $cv = shift;
    my $obj = register( bless \(my $s), __PACKAGE__ );
    $_defer{ id $obj } = $cv;
    return $obj;
}

sub defer (&) {
    my $cv = shift;
    my ($value, $forced);
    my $obj = register( bless \(my $s), __PACKAGE__ );
    $_defer{ id $obj } = sub {
        $forced ? $value : scalar (++$forced, $value = &$cv)
    };
    return $obj;
}

1;

__END__

=head1 NAME

Data::Defer - Calculate values on demand

=head1 SYNOPSIS

    use Data::Defer; # exports 'defer' and 'lazy'

    my ($x, $y);
    my $dv = defer { ++$y };    # a defer-value (not memoized)
    my $lv = lazy { ++$x };     # a lazy-value (memoized)

    print "$dv $dv $dv"; # 1 2 3
    print "$lv $lv $lv"; # 1 1 1

=head1 DESCRIPTION

This module exports two functions, C<defer> and C<lazy>, for building
values that are evaluated on demand.

=head2 defer {...}

Takes a block or a code reference, and returns an overloaded value.
Each time that value is demanded, the block is evaluated again to
yield a fresh result.

=head2 lazy {...}

Like C<defer>, except the value is computed at most once.  Subsequent
evaluation will simly use the cached result.

=head1 NOTES

Unlike the C<tie> based L<Data::Lazy>, this module operates on I<values>,
not I<variables>.  Therefore, assigning into C<$t> simply replaces the value.

The C<overload> based implementation also makes this module about 2x faster
than L<Data::Lazy>.

=head1 AUTHORS

Audrey Tang E<lt>cpan@audreyt.orgE<gt>

=head1 COPYRIGHT (The "MIT" License)

Copyright 2002-2006 by Audrey Tang <cpan@audreyt.org>.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is fur-
nished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIT-
NESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE X
CONSORTIUM BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=cut
