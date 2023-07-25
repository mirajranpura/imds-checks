#!/bin/bash

node_name () {
        [[ ! -z "$MY_NODE_NAME" ]] && echo $MY_NODE_NAME || echo "EmptyNodeName (Ignore)"
}
check_imds_v1 () {

        status_code_v1=$(curl --write-out %{http_code} --silent --output /dev/null http://169.254.169.254/latest/meta-data/ --max-time 3)

        if [[ "$status_code_v1"  -eq 200 ]] ; then
                echo -e "***********\n"
                echo -e "IMDS V1 for pods : Enabled\n" "Found instance ID with IMDS v1: " $(curl http://169.254.169.254/latest/meta-data/instance-id --silent)
        else
                echo -e "***********\n"
                echo -e "IMDS V1 for pods : Disabled"
        fi
}
check_imds_v2 () {

        TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" --silent --max-time 3`

        if [[ ! -z "$TOKEN" ]]
        then
                echo -e "IMDS V2 for pods : Enabled\n" "Found instance ID with IMDS v2: " $(curl http://169.254.169.254/latest/meta-data/instance-id -H "X-aws-ec2-metadata-token: $TOKEN" --silent)
                echo -e $(date) $(node_name)
        else
                echo -e "IMDS V2 for pods :  Disabled\n"
                echo -e $(date) $(node_name)
        fi
}

while true; do check_imds_v1;check_imds_v2;sleep 5s;done
