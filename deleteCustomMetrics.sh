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
delete_all_metrics()
{
    echo "#################################################"
    echo "Deleting metrics"
    echo "#################################################"
    delete_metric_loop
    echo "#################################################"
    echo "waiting 20 seconds to ensure deleted"
    echo "#################################################"
    sleep 20
    echo "#################################################"
    echo "Running Delete again as to verify they are gone"
    echo "Message 'The given timeseries id is not configured'" 
    echo "means metric is gone"
    echo "#################################################"
    delete_metric_loop
}

# this routine loops to delete each metric
delete_metric_loop()
{
    # need to put in UTC milliseconds
    export UNIX_START_TIMESTAMP=$(date -u +"%s")000
    index=0
    for i in ${METRICS[@]}; do
        delete_metric ${METRICS[index]}
        index=$(( index + 1 ))
    done
}

# this is the sub-function called by delete_all_metrics() for one metric
delete_metric() 
{
    # $1 = time series metric ID
    echo "deleting 'custom:$1' metric"
    curl -X DELETE \
    "$DT_TENANT_URL/api/v1/timeseries/custom:$1?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json'
    echo ""
}

########################################
# Main routine
########################################
delete_all_metrics