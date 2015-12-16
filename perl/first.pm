use strict;
use warnings;

our $v1 = 1;
my $v2 = 3;
{
	$v1 = 2;
	my $v2 = 4;
	print $v1, "\n";
	print $v2, "\n";
}
print $v1, "\n";
print $v2, "\n";
