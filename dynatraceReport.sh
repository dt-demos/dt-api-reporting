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

# get data from dynatrace and load into METRICS_DATA string array
source ./queryDynatrace.lib
query_dynatrace

echo "=================================================="
echo "Dynatrace API Report"
echo "Using: $DT_TENANT_URL"
echo "Counts are from : $REPORT_START_TIME"
echo "             to : $REPORT_END_TIME"
echo "Management Zone = $MANAGEMENT_ZONE"
echo "--------------------------------------------------"
echo "Open and Closed problem counts"
echo "--------------------------------------------------"
echo "# Impacting applications   : $PROBLEM_APPLICATION_COUNT"
echo "# Impacting services:      : $PROBLEM_SERVICE_COUNT"
echo "# Impacting infrastructure : $PROBLEM_INFRASTRUCTURE_COUNT"
echo "# User sessions            : $USER_SESSION_COUNT"
echo "--------------------------------------------------"
echo "Entity counts"
echo "--------------------------------------------------"
echo "Applications               : $APPLICATION_COUNT"
echo "Services                   : $SERVICE_COUNT"
echo "Hosts                      : $HOST_COUNT"
echo "--------------------------------------------------"
echo "Same data as above, but in CSV format:"
echo "REPORT_START_TIME,REPORT_END_TIME,PROBLEM_SERVICE_COUNT,PROBLEM_INFRASTRUCTURE_COUNT,PROBLEM_APPLICATION_COUNT,APPLICATION_COUNT,HOST_COUNT,SERVICE_COUNT"
echo "$REPORT_START_TIME,$REPORT_END_TIME,$PROBLEM_SERVICE_COUNT,$PROBLEM_INFRASTRUCTURE_COUNT,$PROBLEM_APPLICATION_COUNT,$APPLICATION_COUNT,$HOST_COUNT,$SERVICE_COUNT"
echo "=================================================="

