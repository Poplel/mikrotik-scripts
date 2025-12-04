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
