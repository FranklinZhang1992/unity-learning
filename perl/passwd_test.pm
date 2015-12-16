use warnings;
use strict;

sub get_doh_session
{
    print "hello\n";
    my @salt1 = ("a", "v", "a", "n", "c", "e");
    my @salt2 = ("E", "V", "E", "R", "r", "u", "n");
    my @secret = ("N", "N", "Y");

    my $pw = "]       ^[^T+/&^V^M^T^R)o";
    my @pass = split //, $pw;
    for (my $i = 0; $i < @pass; $i++) {
    $pass[$i] = $pass[$i] ^ $salt2[$i % @salt2];
    $pass[$i] = $pass[$i] ^ $secret[$i % @secret];
    $pass[$i] = $pass[$i] ^ $salt1[$i % @salt1];
    }
    $pw = join('',@pass);
    print $pw;
    print "\n";
    return;
}

get_doh_session
