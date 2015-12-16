sub create_guest
{
    my $cmd_curl_create_guest =  "<request id='1' target='vm'><create-dynamic><name>test-vm</name><description></description><virtual-cpus>1</virtual-cpus><memory>500</memory><availability-level>FT</availability-level><virtualization>hvm</virtualization><autostart>false</autostart>";
    $cmd_curl_create_guest .="<volume></volume>"."</create-dynamic></request>";
    print $cmd_curl_create_guest
}

create_guest