#!/bin/bash

clear
# load in the Dynatrace URL and API token
export DT_TENANT_URL=$(cat creds.json | jq -r '.dynatraceUrl')
export DT_API_TOKEN=$(cat creds.json | jq -r '.dynatraceApiToken')

if [ $DT_TENANT_URL == "DYNATRACE_URL_PLACEHOLDER" ]; then
    echo "ERROR: Make a copy of creds.sav as creds.json"
    echo "       and udpate with your Dynatrace URL and API token"
    exit 1
fi

export DEVICE_ID=adoption.report.9
# Dynatrace icon
export DEVICE_ICON="https://d2ki1uyufn7sj9.cloudfront.net/1.165.177.20190321-192427/ruxit/public/favicon20150409.ico"

# IFS will adjust the internal file seperator so that space in the metric names work
IFS=""
# load in the metric arrays that are shared across scripts
source ./metrics.lib

# get data from dynatrace and load into METRICS_DATA string array
source ./queryDynatrace.lib

# call this to add data and create the custom device
# assumes metrics and data are in the arrays
# will take usually a minute before aggregated into Dynatrace UI
add_device_data()
{
    # get data to load
    query_dynatrace

    echo "#################################################"
    echo "Adding data"
    echo "#################################################"
    # need to put in UTC milliseconds
    export UNIX_START_TIMESTAMP=$(date -u +"%s")000
    index=0
    for i in ${METRICS[@]}; do
        add_one_metric_data $DEVICE_ID ${METRICS[index]} $UNIX_START_TIMESTAMP ${METRICS_DATA[index]}
        index=$(( index + 1 ))
    done
    echo "#################################################"
    echo "Done."
    echo "#################################################"
}

# this is the sub-function called by add_device_data() for one metric
# if this is used to make the device, then the attributes for
# displayName, group, etc must be provided as to not have a device
# with no context information
add_one_metric_data() 
{
    # $1 = Device ID
    # $2 = time series metric ID
    # $3 = time stamp
    # $4 = metric
    echo "adding data to device '$1' for timeseriesId '$2'"
    curl -X POST \
    "$DT_TENANT_URL/api/v1/entity/infrastructure/custom/$1?Api-Token=$DT_API_TOKEN" \
    -H 'Content-Type: application/json' \
    -d '{
        "displayName" : "Dyntrace Adoption Reporting",
        "group" : "Dyntrace Reporting",
        "favicon" : "'"$DEVICE_ICON"'",
        "unit" : "Count",
        "type": "custom",
        "properties" : {
            "Description": "Used to collect Dynatrace Adoption Metrics"    
        },
        "tags": [
            "Adoption Reporting"
        ],
        "series" : [
            {
                "timeseriesId" : "custom:'"$2"'",
                "dataPoints" : [
                    [ '"$3"', '"$4"' ]
                ]
            }
        ]
    }'
    echo ""
    echo ""
}

########################################
# Main routine
########################################
add_device_data
