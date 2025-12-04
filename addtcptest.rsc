# TO RUN
# First upload the .rsc file to the mikrotik from the files tab
# Open a terminal and type /import addtcptest.rsc
# You should see "Script file loaded and executed successfully"
# You can also check it loaded correctly by going to System > Scripts > Enviroment
# If the function is successfully added you can run it in the terminal with this syntax:
# $tcptest <number of pings> <url to ping> <port to ping>
# Any field not specified will be filled with the fallback defaults below
# This just checks for a HTTP 200 OK response from the specified server, any other response will be marked as a failed ping.

:global tcptest do={
    :local count $1;
    :local host $2;
    :local port $3;

    # Fallback defaults
    # httptest.pophosting.xyz is hosted by me and just returns http status 200 OK on port 8089, other ports will give a 404

    :if ([:len $count] = 0) do={ :set count 10 }
    :if ([:len $host] = 0) do={ :set host "httptest.pophosting.xyz" }
    :if ([:len $port] = 0) do={ :set port "8089" }

    :local failureCount 0;
    :local dialCount 0;

    :put "--- TCP Test Started---";

    :for i from=1 to=$count do={
        :set dialCount ($dialCount + 1);

        :do {
            :local fetchResult [/tool fetch \
                url=("http://" . $host . ":" . $port . "/") \
                output=user \
                idle-timeout=1s \
                duration=2s \
                as-value];

            :if ($fetchResult->"data" = "OK") do={
                :put "Dial $dialCount: SUCCESS";
            } else={
                :set failureCount ($failureCount + 1);
                :put ("Dial $dialCount: FAILED expected ok got: " . ($fetchResult->"data"));
            }
        } on-error={
            :set failureCount ($failureCount + 1);
            :put "Dial $dialCount: FAILED (Connection Refused or Timeout)";
        }
        :delay 0.5s;
    }

    :put "--- Test Complete ---";
    :put "Total: $count";
    :put "Fails: $failureCount";
    :put "Success rate: $((($count - $failureCount) * 100) / $count)%";
    :put "Failure rate: $(($failureCount * 100) / $count)%";
}
