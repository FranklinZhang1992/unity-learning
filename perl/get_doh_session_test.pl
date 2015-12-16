use strict;
use warnings;

sub get_doh_session
{

    my @salt1 = ("a", "v", "a", "n", "c", "e");
    my @salt2 = ("E", "V", "E", "R", "r", "u", "n");
    my @secret = ("N", "N", "Y");

    my $pw = "[Z^Y^Yf%'I^A]^V^?,";
    print $pw, "\n";
    my @pass = split //, $pw;
    print @pass, "\n";
    print "1. pass 2. salt2 3. secret 4. salt1\n";
    print "i=x => 1 || 2 || 3 || 4 || XXX\n";
    print "=================================\n";
    for (my $i = 0; $i < @pass; $i++) {
        print "i=", $i, " => ";
        print $pass[$i], " || ";
        print $salt2[$i % @salt2], " || ";
        print $secret[$i % @secret], " || ";
        print $salt1[$i % @salt1], " || ";
    $pass[$i] = $pass[$i] ^ $salt2[$i % @salt2];
    print $pass[$i], " ";
    $pass[$i] = $pass[$i] ^ $secret[$i % @secret];
    print $pass[$i], " ";
    $pass[$i] = $pass[$i] ^ $salt1[$i % @salt1];
    print $pass[$i], "\n";
    }
    print @pass, "\n";
    $pw = join('',@pass);
    print $pw, "\n";
    my $cmd_curl_login = "curl  -s -b cookie_file -c cookie_file -H \"Content-type: text/xml\" -d \"<requests output='NEWJSON'><request id='1' target='session'><login><username>root</username><password>$pw</password></login></request></requests>\" http://localhost/doh/";

    return;
}

sub test
{
    # my $pw = "[Z^Y^Yf%'I^A]^V^?,";
    # my $pw = "1:2:3:4:5";
    # my @pass = split /:/, $pw;
    # print @pass[0], "\n";
    print "14#+'XI,+(WB", "\n";
}

# get_doh_session
test
