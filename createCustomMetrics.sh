#!/bin/bash

clear
# load in the Dynatrace URL and API token
export DT_TENANT_URL=$(cat creds.json | jq -r '.dynatraceUrl')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')

if [ $DT_TENANT_URL == "DYNATRACE_URL_PLACEHOLDER" ]; then
    echo "ERROR: Make a copy of creds.sav as creds.json"
    echo "       then update it with your Dynatrace URL and API token"
    exit 1
fi

# IFS will adjust the internal file seperator so that space in the metric names work
IFS=""
# load in the metric arrays that are shared across scripts
source ./metrics.lib

# call this to remove the metrics and all associated data
source ./deleteCustomMetrics.sh

# call this to add the metrics.  You can call this again
# with updates to values like display name.
# if you need to change the metric ID, you must delete with the original name 
# and then add the metric with the new name
add_all_metrics()
{
    echo "#################################################"
    echo "Adding metrics"
    echo "#################################################"

    # need to put in UTC milliseconds
    export UNIX_START_TIMESTAMP=$(date -u +"%s")000
    index=0
    for i in ${METRICS[@]}; do
        add_metric ${METRICS[index]} ${METRICS_NAME[index]}
        index=$(( index + 1 ))
    done
    echo "#################################################"
    echo "Done."
    echo "#################################################"
}

# this is the sub-function called by add_all_metrics() for one metric
add_metric() 
{
    # $1 = time series metric ID
    # $2 = time series metric display name
    echo "adding 'custom:$2' metric"
    curl -X PUT \
    "$DT_TENANT_URL/api/v1/timeseries/custom:$1?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -d '{
        "displayName" : "'"$2"'",
        "unit" : "Count",
        "types": [
            "dynatrace"
        ]
    }'
    echo ""
    echo ""
}

########################################
# Main routine
########################################
add_all_metrics
