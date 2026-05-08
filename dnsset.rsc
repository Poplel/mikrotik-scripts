# sets all dhcp network's dns to their gateway
:do {
    /ip dhcp-server network
    :foreach i in=[find] do={
        :local networkGateway [get $i gateway]
        :if ([:len $networkGateway] > 0) do={
            set $i dns-server=$networkGateway
            :log info ("Updated network " . [get $i address] . " to " . $networkGateway)
        }
    }
} on-error={ :log error "DNS set script failed" }
