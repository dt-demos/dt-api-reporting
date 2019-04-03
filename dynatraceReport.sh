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
echo "=================================================="
echo "Counts are from : $REPORT_START_TIME"
echo "             to : $REPORT_END_TIME"
echo "--------------------------------------------------"
echo "PROBLEM_SERVICE:       : $PROBLEM_SERVICE_COUNT"
echo "PROBLEM_INFRASTRUCTURE : $PROBLEM_INFRASTRUCTURE_COUNT"
echo "PROBLEM_APPLICATION    : $PROBLEM_APPLICATION_COUNT"
echo "USER_SESSION_COUNT     : $USER_SESSION_COUNT"
echo "--------------------------------------------------"
echo "Entity counts current"
echo "--------------------------------------------------"
echo "APP_COUNT              : $APPLICATION_COUNT"
echo "HOST_COUNT             : $HOST_COUNT"
echo "SERVICE_COUNT          : $SERVICE_COUNT"
echo "--------------------------------------------------"
echo "Data in CSV format:"
echo "REPORT_START_TIME,REPORT_END_TIME,PROBLEM_SERVICE,PROBLEM_INFRASTRUCTURE,PROBLEM_APPLICATION,APP_COUNT,HOST_COUNT,SERVICE_COUNT"
echo "$REPORT_START_TIME,$REPORT_END_TIME,$PROBLEM_SERVICE,$PROBLEM_INFRASTRUCTURE,$PROBLEM_APPLICATION,$APP_COUNT,$HOST_COUNT,$SERVICE_COUNT"
echo "=================================================="

